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

pub type Case {
  Case(pwd: String, deps: List(String))
}

pub fn scaffold(case_: Case) {
  let src_dir = filepath.join(case_.pwd, "src")
  let test_dir = filepath.join(case_.pwd, "test")
  let assert Ok(_) = simplifile.create_directory_all(src_dir)
  let assert Ok(_) = simplifile.create_directory_all(test_dir)

  let assert Ok(_) =
    simplifile.write(gleam_toml, to: filepath.join(case_.pwd, "gleam.toml"))
}

pub fn main_module(case_: Case, contents: String) {
  let src_dir = filepath.join(case_.pwd, "src")
  let assert Ok(_) =
    simplifile.write(contents, to: filepath.join(src_dir, "app.gleam"))
}

pub fn install_dep(case_: Case, dep: String) -> Result(String, Nil) {
  let out =
    shellout.command(run: "gleam", with: ["add", dep], in: case_.pwd, opt: [])

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

pub fn gleam_check(case_: Case) -> Result(String, String) {
  let out =
    shellout.command(run: "gleam", with: ["check"], in: case_.pwd, opt: [])

  case out {
    Error(#(_, err)) -> Error(err)
    Ok(out) -> Ok(out)
  }
}

pub fn cleanup(case_: Case) {
  simplifile.delete_all([case_.pwd])
}

pub fn defer(cleanup: fn() -> a, body: fn() -> b) {
  body()
  cleanup()
}
