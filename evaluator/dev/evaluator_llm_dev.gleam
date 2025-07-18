import evaluator/llm
import gleeunit/should

pub fn main() -> Nil {
  prompt_openai_test()
  prompt_gemini_test()
  prompt_anthropic_test()
}

fn prompt_openai_test() {
  llm.prompt(llm.GPT4o, "you are a calculator. output only the result.", "5+4")
  |> should.equal(Ok("9"))

  llm.prompt(llm.O4mini, "you are a calculator. output only the result.", "5+4")
  |> should.equal(Ok("9"))
}

fn prompt_gemini_test() {
  llm.prompt(
    llm.Gemini25flash,
    "you are a calculator. output only the result.",
    "5+4",
  )
  |> should.equal(Ok("9"))

  llm.prompt(
    llm.Gemini25pro,
    "you are a calculator. output only the result.",
    "5+4",
  )
  |> should.equal(Ok("9"))
}

fn prompt_anthropic_test() {
  llm.prompt(
    llm.Claude37Sonnet,
    "you are a calculator. output only the result.",
    "5+4",
  )
  |> should.equal(Ok("9"))

  llm.prompt(
    llm.ClaudeSonnet4,
    "you are a calculator. output only the result.",
    "5+4",
  )
  |> should.equal(Ok("9"))
}
