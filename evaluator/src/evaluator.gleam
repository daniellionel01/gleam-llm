import evaluator/project
import gleeunit/should

fn run_case() {
  todo
}

pub fn main() {
  case_1()
}

fn case_1() {
  let pwd = project.tmp_pwd()
  let thecase = project.Project(pwd)
  use <- project.defer(fn() { project.cleanup(thecase) })

  project.scaffold(thecase)
  |> should.be_ok()

  project.install_dep(thecase, "argv")
  |> should.be_ok()

  project.main_module(
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
  )
  |> should.be_ok()

  let assert Ok(_) = project.gleam_check(thecase)

  let assert Ok(_) = project.gleam_build(thecase)

  echo pwd
  project.gleam_run(thecase, ["--no-print-progress", "test"])
}
