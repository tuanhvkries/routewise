class LlmClient
  def self.ask_json!(instructions:, prompt:, model: "gpt-4o-mini")
    raw = with_retries do
      RubyLLM.chat(model: model)
        .with_instructions(instructions)
        .ask(prompt)
        .content.to_s
    end

    JSON.parse(extract_json(raw))
  end

  def self.with_retries(max_attempts: 4, base_sleep: 1.0)
    attempt = 0
    begin
      attempt += 1
      yield
    rescue RubyLLM::RateLimitError, RubyLLM::ServiceUnavailableError, RubyLLM::ServerError,
           Faraday::TimeoutError, Faraday::ConnectionFailed => e
      raise if attempt >= max_attempts

      sleep_for = (base_sleep * (2**(attempt - 1))) + rand * 0.25
      Rails.logger.warn("[LlmClient] retry #{attempt}/#{max_attempts} after #{e.class}: sleep #{sleep_for.round(2)}s")
      sleep(sleep_for)
      retry
    end
  end

  def self.extract_json(text)
    start = text.index("{")
    finish = text.rindex("}")
    return text if start.nil? || finish.nil?
    text[start..finish]
  end
end
