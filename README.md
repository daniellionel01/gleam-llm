# Gleam LLM

A report on abilities of various popular LLMs to write correct [gleam](https://gleam.run/) code.

**This project is a work in progress and not complete! No results have been concluded yet.**

## Introduction

At the time of this writing (June 2025), LLMs across the board are quite bad at writing gleam code.
They hallucinate syntax (if statements), hallucinate functions from the stdlib, forget to unwrap result type,
and do not know how to leverage `use`.

Since gleam itself is quite a minimalistic language, I think it would not take much additional context for a
LLM to be able to write quality gleam code. If we made this work, this should yield in a powerful agentic coding
assistant. Coupled with quick feedback loops that it achieves with a compiler that gives useful error messages.

*Disclaimer: pretty much all information in here is subject to change at least every couple of months
as new models come out, existing models are updated and prices change.*

## Methodology

To achieve our goal, here is an outline of our approach:

1. create an evaluator that takes a case (which is a description of a gleam program for the LLM), prompts the LLM
  and automatically evaluates the output, giving it a maximum of 5 iterations to give us a correct gleam program.
2. analyse weak points of common failures across llms and cases (f.e. a certain aspect of the gleam syntax)
3. come up with different llm.txt and run evaluator again, this time with the llm.txt as additional context
4. identify and compress most efficient llm.txt as much as possible, as to keep cost as low as possible while
  prioritising program correctness (only 100% is acceptable).

## Evaluator

[Evaluator Code](./evaluator)

These are the cases we are going to let the LLM attempt to implement:
- simple hello world
- matrix multiplication
- exercism challenge
- advent of code challenge
- something with generics and more complex type apis
- a little auth library that works with hashes
- web server that renders some html
- web server json api
- `use` utility (like given library)
- write ffi for npm & elixir package
- write something with erlang & otp

These are the LLM providers we are going to prompt:
- gpt-4o-2024-11-20
- o4-mini-2025-04-16
- claude-3-7-sonnet-20250219
- claude-sonnet-4-20250514
- gemini-2.5-flash-preview-05-20
- gemini-2.5-pro-preview-06-05

A case is already prepared with all required dependencies.

## LLM.txt

## Reports

https://htmlpreview.github.io/?https://github.com/daniellionel01/gleam-llm/blob/main/evaluator/priv/report.html

## Access to Dependency Docs

Making the LLM be able to produce syntactically correct gleam was not the hard part. The hard part is the everychanging
landscape and api of gleam packages that are being used.

## MCP Server

## Conclusion

Since the llm.txt would be given to every new thread with a LLM, let us break down the costs for the providers (https://llm-stats.com/):
