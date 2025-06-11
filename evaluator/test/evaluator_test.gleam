import evaluator/case_
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn case_scaffold_test() {
  let pwd = case_.tmp_pwd()
  let thecase = case_.Case(pwd, [])
  use <- case_.defer(fn() { case_.cleanup(thecase) })

  case_.scaffold(thecase)
  |> should.be_ok()

  case_.cleanup(thecase)
}

pub fn case_check_successfull_test() {
  let pwd = case_.tmp_pwd()
  let thecase = case_.Case(pwd, [])
  use <- case_.defer(fn() { case_.cleanup(thecase) })

  case_.scaffold(thecase)
  |> should.be_ok()

  case_.main_module(
    thecase,
    "
pub fn main() {
  echo \"hello!\"
}
",
  )
  |> should.be_ok()

  case_.gleam_check(thecase)
  |> should.be_ok()
}

pub fn case_check_error_test() {
  let pwd = case_.tmp_pwd()
  let thecase = case_.Case(pwd, [])
  use <- case_.defer(fn() { case_.cleanup(thecase) })

  case_.scaffold(thecase)
  |> should.be_ok()

  case_.main_module(
    thecase,
    "
pub fn main() -> Int {
  echo \"hello!\"
}
",
  )
  |> should.be_ok()

  case_.gleam_check(thecase)
  |> should.be_error()
}
