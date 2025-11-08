#!/bin/bash

podman --log-level=error build -q -t gleam-llm .
podman run --rm gleam-llm bash -lc '
set +e

echo -n "Python: " ; python3 --version 2>/dev/null || echo "not found"
echo -n "Bun: "    ; bun --version 2>/dev/null || echo "not found"
echo -n "Go: "     ; go version 2>/dev/null || echo "not found"
echo -n "Rust: "   ; rustc --version 2>/dev/null || echo "not found"
echo -n "Cargo: "  ; cargo --version 2>/dev/null || echo "not found"
echo -n "OCaml: "  ; ocamlc -version 2>/dev/null || echo "not found"
echo -n "Elixir: " ; elixir -e "IO.puts(System.version())" 2>/dev/null || echo "not found"
echo -n "Erlang: " ; erl -noshell -eval "io:format(\"~s~n\",[erlang:system_info(otp_release)]), halt()." 2>/dev/null || echo "not found"
'
