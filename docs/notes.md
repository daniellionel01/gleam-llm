# Notes

## goals

- create automations for llms to create gleam program and verify
- find out current state of LLMs to create correct gleam programs
- create llm.txt

## tests

- metrics
  - how many iterations did it take?
  - how much information is necessary?
  - what aspects of gleam are most commonly used incorrectly?
    (f.e. imports, hallucinating functions on modules, type mismatch, ...)

- open questions:
  - how many iterations should be the max. for a LLM to try?

## todo
  - [x] cache report results as json
  - [ ] generated html report
    - [ ] display case contents inside of accordion
    - [ ] charts how well certain models do over all cases
    - [ ] nicer styling & formatting
    - [ ] code highlighting
  - [ ] allow for multiple iterations for model on case and give it gleam compiler output to allow it to attempt and fix its own mistake/s

## miscelleaneous


- baseline with other languages
  - python (with uv)
  - javascript
  - golang

- adjust max_tokens in anthropic api?

- html to markdown
  - https://github.com/JohannesKaufmann/html-to-markdown

- llm.txt inspiration
  - https://llmstxt.new/
  - https://llmstxt.org/
  - https://daisyui.com/llms.txt
  - https://bun.sh/llm.txt
  - https://svelte.dev/docs/llms

- https://tour.gleam.run/everything/
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
- additional information
  - gleam cli
  - how to download package documentation
  - how to get more information on certain packages
