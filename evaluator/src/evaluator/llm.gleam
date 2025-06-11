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

pub type Provider {
  OpenAI
  Gemini
  Anthropic
}

pub type Model {
  GPT4o
  O4mini
  Claude37Sonnet
  ClaudeSonnet4
  Gemini25flash
  Gemini25pro
}

pub fn prompt(
  model: Model,
  system: String,
  user: String,
) -> Result(String, LLMError) {
  let provider = get_provider(model)

  let assert Ok(base_req) =
    provider_base_url(model)
    |> request.to()

  let body = make_body(model, system, user)

  let req =
    base_req
    |> request.set_method(http.Post)
    |> request.set_body(body)
    |> request.prepend_header("Content-Type", "application/json")
    |> auth_request(provider)

  use resp <- result.try(
    result.map_error(httpc.send(req), fn(e) { RequestError(e) }),
  )

  let decoder = provider_decoder(provider)
  use data <- result.try(
    result.map_error(json.parse(from: resp.body, using: decoder), fn(err) {
      ResponseError(err)
    }),
  )

  use choice <- result.try(
    result.map_error(flatten_decoded_result(data), fn(_) { EmptyResponseError }),
  )

  Ok(choice)
}

pub fn make_body(model: Model, system: String, user: String) {
  let provider = get_provider(model)
  case provider {
    OpenAI -> {
      let model_id = model_to_identifier(model)

      let messages = [
        [#("role", json.string("system")), #("content", json.string(system))],
        [#("role", json.string("user")), #("content", json.string(user))],
      ]
      json.object([
        #("model", json.string(model_id)),
        #("messages", json.array(messages, of: json.object)),
      ])
      |> json.to_string()
    }
    Gemini -> {
      json.object([
        #(
          "system_instruction",
          json.object([
            #(
              "parts",
              json.array([[#("text", json.string(system))]], of: json.object),
            ),
          ]),
        ),
        #(
          "contents",
          json.object([
            #(
              "parts",
              json.array([[#("text", json.string(user))]], of: json.object),
            ),
          ]),
        ),
      ])
      |> json.to_string()
    }
    Anthropic -> todo
  }
}

pub fn auth_request(req: request.Request(a), provider: Provider) {
  let env = env.get_env()
  case provider {
    OpenAI ->
      request.prepend_header(req, "Authorization", "Bearer " <> env.openai_key)
    Gemini -> request.set_query(req, [#("key", env.gemini_key)])
    Anthropic -> todo
  }
}

pub fn provider_base_url(model: Model) {
  let provider = get_provider(model)
  case provider {
    OpenAI -> "https://api.openai.com/v1/chat/completions"
    Gemini -> {
      let model = model_to_identifier(model)
      "https://generativelanguage.googleapis.com/v1beta/models/"
      <> model
      <> ":generateContent"
    }
    Anthropic -> todo
  }
}

pub type DecodedResult {
  List1(List(String))
  List2(List(List(String)))
}

pub fn flatten_decoded_result(res: DecodedResult) {
  case res {
    List1(res) -> list.first(res)
    List2(res) -> {
      case list.first(res) {
        Error(_) -> Error(Nil)
        Ok(res) -> list.first(res)
      }
    }
  }
}

pub fn provider_decoder(provider: Provider) -> decode.Decoder(DecodedResult) {
  case provider {
    OpenAI -> {
      let message_decoder = {
        use content <- decode.field("content", decode.string)
        decode.success(content)
      }
      let choices_decoder = {
        use message <- decode.field("message", message_decoder)
        decode.success(message)
      }
      use choices <- decode.field("choices", decode.list(choices_decoder))
      decode.success(List1(choices))
    }
    Gemini -> {
      let parts_decoder = {
        use text <- decode.field("text", decode.string)
        decode.success(text)
      }
      let content_decoder = {
        use parts <- decode.field("parts", decode.list(parts_decoder))
        decode.success(parts)
      }
      let candidates_decoder = {
        use content <- decode.field("content", content_decoder)
        decode.success(content)
      }
      use candidates <- decode.field(
        "candidates",
        decode.list(candidates_decoder),
      )
      decode.success(List2(candidates))
    }
    Anthropic -> todo
  }
}

pub fn model_to_identifier(model: Model) -> String {
  case model {
    GPT4o -> "gpt-4o-2024-11-20"
    O4mini -> "o4-mini-2025-04-16"
    Claude37Sonnet -> "claude-3-7-sonnet-20250219"
    ClaudeSonnet4 -> "claude-sonnet-4-20250514"
    Gemini25flash -> "gemini-2.5-flash-preview-05-20"
    Gemini25pro -> "gemini-2.5-pro-preview-06-05"
  }
}

pub fn get_provider(model: Model) {
  case model {
    GPT4o -> OpenAI
    O4mini -> OpenAI
    Claude37Sonnet -> Anthropic
    ClaudeSonnet4 -> Anthropic
    Gemini25flash -> Gemini
    Gemini25pro -> Gemini
  }
}
