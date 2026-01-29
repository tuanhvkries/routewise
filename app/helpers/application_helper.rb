module ApplicationHelper
CO2_feature
  def eco_rating_leaves(co2_kg)
    # Lower CO2 = more leaves (more eco-friendly)
    # Thresholds based on typical transport emissions
    rating = case co2_kg.to_f
             when 0..20 then 5    # Very eco-friendly (train, bus)
             when 20..50 then 4
             when 50..100 then 3
             when 100..200 then 2
             else 1               # High emissions (flights)
             end

    filled = '<i class="fa-solid fa-leaf" style="color: #22c55e;"></i>' * rating
    empty = '<i class="fa-light fa-leaf" style="color: #d1d5db;"></i>' * (5 - rating)

    (filled + empty).html_safe
   end
  def minutes_to_hours(minutes)
    return "" if minutes.blank?

    total = minutes.to_i
    h = total / 60
    m = total % 60
    "#{h}h#{format('%02d', m)}"

  end
end
