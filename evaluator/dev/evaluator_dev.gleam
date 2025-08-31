import evaluator/llm/openrouter

pub fn main() {
  echo openrouter.completion(openrouter.GPT5Mini, [
    openrouter.Message(
      openrouter.System,
      "You are a calculator. Output only the numeric result",
    ),
    openrouter.Message(openrouter.User, "5 + 8"),
  ])
}
