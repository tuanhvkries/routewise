# Be sure to restart your server when you modify this file.

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data

  # Allow Unsplash images
  policy.img_src     :self, :https, :data,
                     "https://images.unsplash.com",
                     "https://source.unsplash.com"

  policy.object_src  :none
  policy.script_src  :self, :https, :unsafe_inline, :blob
  policy.style_src   :self, :https, :unsafe_inline
  policy.worker_src  :self, :blob
end
