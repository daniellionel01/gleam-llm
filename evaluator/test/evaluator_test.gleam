import evaluator/case_
import gleam/result
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn case_scaffold_test() {
  let pwd = case_.tmp_pwd()
  let thecase = case_.Case(pwd)
  use <- case_.defer(fn() { case_.cleanup(thecase) })

  assert result.is_ok(case_.scaffold(thecase))

  case_.cleanup(thecase)
}

pub fn case_check_successfull_test() {
  let pwd = case_.tmp_pwd()
  let thecase = case_.Case(pwd)
  use <- case_.defer(fn() { case_.cleanup(thecase) })

  assert result.is_ok(case_.scaffold(thecase))

  assert result.is_ok(case_.main_module(
    thecase,
    "
pub fn main() {
  echo \"hello!\"
}
",
  ))

  assert result.is_ok(case_.gleam_check(thecase))
}

pub fn case_check_error_test() {
  let pwd = case_.tmp_pwd()
  let thecase = case_.Case(pwd)
  use <- case_.defer(fn() { case_.cleanup(thecase) })

  assert result.is_ok(case_.scaffold(thecase))

  assert result.is_ok(case_.main_module(
    thecase,
    "
pub fn main() -> Int {
  echo \"hello!\"
}
",
  ))

  assert result.is_error(case_.gleam_check(thecase))
}

pub fn case_run_with_deps_test() {
  let pwd = case_.tmp_pwd()
  let thecase = case_.Case(pwd)
  use <- case_.defer(fn() { case_.cleanup(thecase) })

  assert result.is_ok(case_.scaffold(thecase))

  assert result.is_ok(case_.install_dep(thecase, "argv"))

  assert result.is_ok(case_.main_module(
    thecase,
    "
import gleam/io
import argv

pub fn main() {
  case argv.load().arguments {
    [arg] -> io.println(arg)
    _ -> Nil
  }
}
",
  ))

  assert result.is_ok(case_.gleam_check(thecase))

  assert result.is_ok(case_.gleam_build(thecase))

  assert case_.gleam_run(thecase, ["--no-print-progress", "test"])
    == Ok("test\n")
}
