# Notes

## metrics

- how many iterations did it take?
- how much information is necessary?
- what aspects of gleam are most commonly used incorrectly?
  (f.e. imports, hallucinating functions on modules, type mismatch, ...)

## open questions
- how many iterations should be the max. for a LLM to try?

## todo
- [ ] sqlite database
  - [ ] profiles: id, max_iterations, models to test
  - [ ] case: id, slug, description
  - [ ] case run: programming language, model, case,
- [ ] populate openai models from api?
- [ ] programming languages type: javascript, typescript,
- [ ] programming language engine: code -> stdout, dependencies, system prompt
- [ ] allow for multiple iterations for model on case and give it gleam compiler output to allow it to attempt and fix its own mistake/s
- [ ] charts how well certain models do over all cases
- [ ] demonstrate in real world project setups. f.e. with opencode cli

### code evaluation

- [ ] make version with podman

- [ ] baseline with other languages
  - [ ] python (with uv)
  - [ ] javascript (with bun)
  - [ ] haskell
  - [ ] golang
  - [ ] elixir
  - [ ] rust
  - [ ] ocaml

## miscelleaneous

- [ ] https://github.com/Tencent-Hunyuan/AutoCodeBenchmark/

- [ ] https://gleam.run/case-studies/strand/ quote about AI
  > “We’re heading into a new age of AI-assisted coding, and right now, it’s difficult to predict how that will play out. But if I had to place a bet, I would say that in the long run, AIs are more likely to generate high-quality code in a language like Gleam. Gleam makes it quick and easy for AIs to check their code, get instant feedback, and iterate. That should be an advantage compared to languages that are slow to build, have cryptic error messages, and can’t catch mistakes at build-time.”

- [ ] https://eval.16x.engineer/

- [x] https://openrouter.ai/

- [ ] llm.txt inspiration
  - https://llmstxt.new/
  - https://llmstxt.org/
  - https://daisyui.com/llms.txt
  - https://bun.sh/llm.txt
  - https://svelte.dev/docs/llms

- [ ] https://tour.gleam.run/everything/

- concepts in gleam
  - pattern matching
  - `use`
  - option & result type
  - pipes & function capture
  - functions (pub, types, labels)
  - imports
  - custom types
  - lists
  - arithmetic operations (ints vs floats)
  - panic and todo
  - javascript & erlang ffi

- facts about gleam
  - no early returns
  - everything is an expression
  - immutable
  - no loops, use recursion
  - no if statements, use case

- additional information about gleam
  - latest version
  - changelog
  - gleam cli (`gleam help`)
  - how to download package documentation (`gleam add <package>`)
  - how to get more information on certain packages
