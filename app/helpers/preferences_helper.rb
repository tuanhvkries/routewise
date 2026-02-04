module PreferencesHelper
  PREFERENCE_EMOJIS = {
    "Adventure"      => "🏔️",
    "Architecture"   => "🏛️",
    "Art"            => "🎨",
    "Food"           => "🍽️",
    "Local culture"  => "🧑‍🤝‍🧑",
    "Museum"         => "🏺",
    "Nature"         => "🌿",
    "Party"          => "🥂",
    "Photography"    => "📷",
    "Relaxing"       => "🛋️",
    "Shopping"       => "🛍️",
    "Sport"          => "🏋️",
    "Walking"        => "🚶",
    "Wellness"       => "🧘",
    "Sustainability" => "🌍"
  }.freeze

  def preference_emoji(name)
    PREFERENCE_EMOJIS[name.to_s] || "✨"
  end
end
