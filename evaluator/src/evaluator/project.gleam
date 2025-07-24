import filepath
import gleam/bit_array
import gleam/crypto
import gleam/string
import shellout
import simplifile

const gleam_toml = "name = \"app\"
version = \"1.0.0\"

[dependencies]
gleam_stdlib = \">= 0.44.0 and < 2.0.0\"
"

pub type Project {
  Project(pwd: String)
}

pub fn scaffold(project: Project) {
  let src_dir = filepath.join(project.pwd, "src")
  let test_dir = filepath.join(project.pwd, "test")
  let assert Ok(_) = simplifile.create_directory_all(src_dir)
  let assert Ok(_) = simplifile.create_directory_all(test_dir)

  let assert Ok(_) =
    simplifile.write(gleam_toml, to: filepath.join(project.pwd, "gleam.toml"))
}

pub fn main_module(project: Project, contents: String) {
  let src_dir = filepath.join(project.pwd, "src")
  let assert Ok(_) =
    simplifile.write(contents, to: filepath.join(src_dir, "app.gleam"))
}

pub fn install_dep(project: Project, dep: String) -> Result(String, Nil) {
  let out =
    shellout.command(run: "gleam", with: ["add", dep], in: project.pwd, opt: [])

  case out {
    Error(_) -> Error(Nil)
    Ok(out) -> Ok(out)
  }
}

pub fn tmp_pwd() {
  let uid =
    crypto.strong_random_bytes(12)
    |> bit_array.base16_encode()
    |> string.lowercase()
  "/tmp/" <> uid
}

pub fn gleam_check(project: Project) -> Result(String, String) {
  let out =
    shellout.command(run: "gleam", with: ["check"], in: project.pwd, opt: [])

  case out {
    Error(#(_, err)) -> Error(err)
    Ok(out) -> Ok(out)
  }
}

pub fn gleam_build(project: Project) -> Result(Nil, String) {
  let out =
    shellout.command(run: "gleam", with: ["build"], in: project.pwd, opt: [])
  let _ = echo out

  case out {
    Error(#(_, err)) -> Error(err)
    Ok(_) -> Ok(Nil)
  }
}

pub fn gleam_run(project: Project, args: List(String)) -> Result(String, String) {
  let out =
    shellout.command(
      run: "gleam",
      with: ["run", ..args],
      in: project.pwd,
      opt: [],
    )

  case out {
    Error(#(_, err)) -> Error(err)
    Ok(out) -> Ok(out)
  }
}

pub fn cleanup(project: Project) {
  simplifile.delete_all([project.pwd])
}

pub fn defer(cleanup: fn() -> a, body: fn() -> b) -> b {
  let r = body()
  cleanup()
  r
}
