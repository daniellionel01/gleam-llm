# Gleam LLM

A report on abilities of various popular LLMs to write correct [gleam](https://gleam.run/) code.

## WIP

**This project is a work in progress!**

## Goals

- [ ] create automations for llms to create gleam program and verify
- [ ] find out current state of LLMs to create correct gleam programs
- [ ] create llm.txt

## Tests & Baseline

- metrics
  - how many iterations did it take?
  - how much information is necessary?
  - what aspects of gleam are most commonly used incorrectly?
    (f.e. imports, hallucinating functions on modules, type mismatch, ...)

- llms to test
  - claude
  - gemini
  - openai
  - deepseek r1
  - llama

- programs to test with increasing complexity
  - "hello world"
  - web server that renders some html
  - web server json api
  - pick advent of code challenges
  - write tests for something
  - something with `use`

- open questions:
  - how many iterations should be the max. for a LLM to try?

## LLM.txt

## Random Notes

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
