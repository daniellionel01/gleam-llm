import evaluator/project
import gleam/result
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn project_scaffold_test() {
  let pwd = project.tmp_pwd()
  let project = project.Project(pwd)
  use <- project.defer(fn() { project.cleanup(project) })

  assert result.is_ok(project.scaffold(project))

  project.cleanup(project)
}

pub fn project_check_successfull_test() {
  let pwd = project.tmp_pwd()
  let project = project.Project(pwd)
  use <- project.defer(fn() { project.cleanup(project) })

  assert result.is_ok(project.scaffold(project))

  assert result.is_ok(project.main_module(
    project,
    "
pub fn main() {
  echo \"hello!\"
}
",
  ))

  assert result.is_ok(project.gleam_check(project))
}

pub fn project_check_error_test() {
  let pwd = project.tmp_pwd()
  let project = project.Project(pwd)
  use <- project.defer(fn() { project.cleanup(project) })

  assert result.is_ok(project.scaffold(project))

  assert result.is_ok(project.main_module(
    project,
    "
pub fn main() -> Int {
  echo \"hello!\"
}
",
  ))

  assert result.is_error(project.gleam_check(project))
}

pub fn project_run_with_deps_test() {
  let pwd = project.tmp_pwd()
  let project = project.Project(pwd)
  use <- project.defer(fn() { project.cleanup(project) })

  assert result.is_ok(project.scaffold(project))

  assert result.is_ok(project.install_dep(project, "argv"))

  assert result.is_ok(project.main_module(
    project,
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

  assert result.is_ok(project.gleam_check(project))

  assert result.is_ok(project.gleam_build(project))

  assert project.gleam_run(project, ["--no-print-progress", "test"])
    == Ok("test\n")
}
