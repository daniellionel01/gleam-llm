import envoy

pub type Environment {
  Environment(openai_key: String, gemini_key: String, anthropic_key: String)
}

pub fn get_env() -> Environment {
  let assert Ok(openai_key) = envoy.get("OPENAI_KEY")
  let assert Ok(gemini_key) = envoy.get("GEMINI_KEY")
  let assert Ok(anthropic_key) = envoy.get("ANTHROPIC_KEY")

  Environment(openai_key:, gemini_key:, anthropic_key:)
}
