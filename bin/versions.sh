#!/bin/bash

podman --log-level=error build -q -t gleam-llm .
podman run --rm gleam-llm bash -lc '
set +e

{
  printf "Python|";  python3 --version 2>/dev/null || echo "not found"
  printf "Bun|";     bun --version 2>/dev/null || echo "not found"
  printf "Go|";      go version 2>/dev/null || echo "not found"
  printf "Rust|";    rustc --version 2>/dev/null || echo "not found"
  printf "Cargo|";   cargo --version 2>/dev/null || echo "not found"
  printf "OCaml|";   ocamlc -version 2>/dev/null || echo "not found"
  # Elixir: just the version number
  printf "Elixir|";  elixir -e "IO.puts(System.version())" 2>/dev/null || echo "not found"
  # Erlang: just the OTP release number
  printf "Erlang|";  erl -noshell -eval "io:format(\"~s~n\",[erlang:system_info(otp_release)]), halt()." 2>/dev/null || echo "not found"
} | column -t -s "|"
'
