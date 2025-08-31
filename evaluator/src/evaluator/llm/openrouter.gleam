import env
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/httpc
import gleam/json
import gleam/list
import gleam/result

pub type LLMError {
  RequestError(httpc.HttpError)
  ResponseError(json.DecodeError)
  EmptyResponseError
  UnexpectedError(String)
}

pub type Model {
  GPT5Chat
  GPT5Mini
  GPT5
  O3
  Opus41
  Sonnet4
  Gemini25Pro
  GrokCodeFast
  DeepSeekV3
}

fn model_to_string(model: Model) -> String {
  case model {
    GPT5 -> "openai/gpt5"
    GPT5Chat -> "openai/gpt-5-chat"
    GPT5Mini -> "openai/gpt-5-mini"
    O3 -> "openai/o3"
    Opus41 -> "anthropic/claude-opus-4.1"
    Sonnet4 -> "anthropic/claude-sonnet-4"
    Gemini25Pro -> "google/gemini-2.5-pro"
    GrokCodeFast -> "x-ai/grok-code-fast-1"
    DeepSeekV3 -> "deepseek/deepseek-chat-v3.1"
  }
}

pub type Role {
  System
  User
  Assistant
}

pub type Message {
  Message(role: Role, content: String)
}

pub type Usage {
  Usage(prompt_tokens: Int, completion_tokens: Int, total_tokens: Int)
}

pub type Response {
  Response(usage: Usage, content: String)
}

pub fn completion(
  model: Model,
  messages: List(Message),
) -> Result(Response, LLMError) {
  let env = env.get_env()

  let model_id = model_to_string(model)

  let assert Ok(base_req) =
    "https://openrouter.ai/api/v1/chat/completions"
    |> request.to()

  let messages =
    list.map(messages, fn(msg) {
      let role = case msg.role {
        Assistant -> "assistant"
        System -> "system"
        User -> "user"
      }
      [
        #("role", json.string(role)),
        #("content", json.string(msg.content)),
      ]
    })
  let body =
    json.object([
      #("model", json.string(model_id)),
      #("messages", json.array(messages, of: json.object)),
    ])
    |> json.to_string()

  let req =
    base_req
    |> request.set_method(http.Post)
    |> request.set_body(body)
    |> request.prepend_header("Content-Type", "application/json")
    |> request.prepend_header("Authorization", "Bearer " <> env.openrouter_key)

  let config =
    httpc.configure()
    |> httpc.timeout(60_000)

  use resp <- result.try(
    httpc.dispatch(config, req)
    |> result.map_error(fn(e) { RequestError(e) }),
  )

  let usage_decoder = {
    let usage_decoder = {
      use prompt_tokens <- decode.field("prompt_tokens", decode.int)
      use completion_tokens <- decode.field("completion_tokens", decode.int)
      use total_tokens <- decode.field("total_tokens", decode.int)
      decode.success(Usage(prompt_tokens, completion_tokens, total_tokens))
    }
    use usage <- decode.field("usage", usage_decoder)
    decode.success(usage)
  }
  use usage <- result.try(
    json.parse(from: resp.body, using: usage_decoder)
    |> result.map_error(fn(err) { ResponseError(err) }),
  )

  let content_decoder = {
    let message_decoder = {
      use content <- decode.field("content", decode.string)
      decode.success(content)
    }
    let choices_decoder = {
      use message <- decode.field("message", message_decoder)
      decode.success(message)
    }
    use choices <- decode.field("choices", decode.list(choices_decoder))
    decode.success(choices)
  }
  use content_data <- result.try(
    json.parse(from: resp.body, using: content_decoder)
    |> result.map_error(fn(err) { ResponseError(err) }),
  )
  use content <- result.try(
    list.first(content_data)
    |> result.map_error(fn(_) { EmptyResponseError }),
  )

  let response = Response(usage, content)

  Ok(response)
}
