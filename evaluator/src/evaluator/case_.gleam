import evaluator/llm
import gleam/dynamic/decode
import gleam/json

pub type Evaluation {
  CompileError
  Invalid
  Valid
}

fn evaluation_decoder() -> decode.Decoder(Evaluation) {
  use variant <- decode.then(decode.string)
  case variant {
    "compile_error" -> decode.success(CompileError)
    "invalid" -> decode.success(Invalid)
    "valid" -> decode.success(Valid)
    _ -> decode.failure(Invalid, "Evaluation")
  }
}

pub fn evaluation_from_bool(b: Bool) {
  case b {
    False -> Invalid
    True -> Valid
  }
}

fn evaluation_to_json(evaluation: Evaluation) -> json.Json {
  case evaluation {
    CompileError -> json.string("compile_error")
    Invalid -> json.string("invalid")
    Valid -> json.string("valid")
  }
}

pub type Validator =
  fn(String) -> Bool

pub type Case {
  Case(title: String, contents: String, deps: List(String))
}

fn case_decoder() -> decode.Decoder(Case) {
  use title <- decode.field("title", decode.string)
  use contents <- decode.field("contents", decode.string)
  use deps <- decode.field("deps", decode.list(decode.string))
  decode.success(Case(title:, contents:, deps:))
}

fn case_to_json(case_: Case) -> json.Json {
  let Case(title:, contents:, deps:) = case_
  json.object([
    #("title", json.string(title)),
    #("contents", json.string(contents)),
    #("deps", json.array(deps, json.string)),
  ])
}

pub type Report {
  Report(case_: Case, program: String, model: llm.Model, eval: Evaluation)
}

pub fn report_decoder() -> decode.Decoder(Report) {
  use case_ <- decode.field("case_", case_decoder())
  use program <- decode.field("program", decode.string)
  use model <- decode.field("model", llm.model_decoder())
  use eval <- decode.field("eval", evaluation_decoder())
  decode.success(Report(case_:, program:, model:, eval:))
}

pub fn report_to_json(report: Report) -> json.Json {
  let Report(case_:, program:, model:, eval:) = report
  json.object([
    #("case_", case_to_json(case_)),
    #("program", json.string(program)),
    #("model", llm.model_to_json(model)),
    #("eval", evaluation_to_json(eval)),
  ])
}
