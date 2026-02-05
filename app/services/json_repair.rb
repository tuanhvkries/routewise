# app/services/json_repair.rb
class JsonRepair
  def self.repair(json_text)
    RubyLLM.chat
      .with_instructions(<<~INST)
        You fix invalid JSON.
        Return ONLY valid JSON. No extra text.
        Ensure all numbers are valid JSON numbers (e.g., 59 not 59.; 13.0 not 13.).
        Do not change keys/structure except what is required to make JSON valid.
      INST
      .ask(json_text)
      .content
      .to_s
  end
end
