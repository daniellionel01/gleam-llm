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

To achieve our goal, there are multiple milestones to achieve first:
- create an evaluator that takes a case (which is a description of a gleam program for the LLM), prompts the LLM
  and automatically evaluates the output, giving it a maximum of 5 iterations to give us a correct gleam program.
- analyse weak points of common failures across llms and cases (f.e. a certain aspect of the gleam syntax)
- come up with different llm.txt and run evaluator again, this time with the llm.txt as additional context
- identify and compress most efficient llm.txt as much as possible, as to keep cost as low as possible while
  prioritising program correctness (only 100% is acceptable).

A case is already prepared with all required dependencies.

## Evaluator

## LLM.txt

## Reports

## Conclusion

Since the llm.txt would be given to every new thread with a LLM, let us break down the costs for the providers:
