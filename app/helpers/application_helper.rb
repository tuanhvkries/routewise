module ApplicationHelper
  def minutes_to_hours(minutes)
    return "" if minutes.blank?

    total = minutes.to_i
    h = total / 60
    m = total % 60
    "#{h}h#{format('%02d', m)}"
  end
end
