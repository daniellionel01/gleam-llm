import evaluator/llm
import evaluator/project
import given
import gleam/list
import gleam/string

pub type Evaluation {
  CompileError
  Validated(Bool)
}

pub type Case {
  Case(contents: String, deps: List(String), validator: fn(String) -> Bool)
}

pub fn evaluate_case(case_: Case, llm: llm.Model) -> Result(Evaluation, String) {
  // todo as "get gleam code from llm given the case's description"

  let program: String = todo

  let pwd = project.tmp_pwd()
  let case_project = project.Project(pwd)
  use <- project.defer(fn() { project.cleanup(case_project) })

  let assert Ok(_) = project.scaffold(case_project)
  list.each(case_.deps, fn(dep) {
    let assert Ok(_) = project.install_dep(case_project, dep)
  })

  let assert Ok(_) = project.main_module(case_project, program)

  let compiles = case project.gleam_build(case_project) {
    Ok(_) -> True
    Error(_) -> False
  }
  use <- given.that(!compiles, return: fn() { Ok(CompileError) })
  case project.gleam_run(case_project, ["--no-print-progress", "test"]) {
    Ok(stdout) -> {
      let valid = case_.validator(stdout)
      Ok(Validated(valid))
    }
    Error(_) -> Ok(Validated(False))
  }
}

pub fn main() {
  case_1()
}

pub fn case_1() {
  let case_ =
    Case(contents: "", deps: [], validator: fn(stdout) {
      stdout
      |> string.lowercase()
      |> string.trim()
      == "hello world!"
    })
  echo evaluate_case(case_, llm.GPT4o)
}
