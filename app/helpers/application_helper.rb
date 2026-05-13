module ApplicationHelper
  def format_duration(seconds)
    return "—" unless seconds

    total_min   = (seconds / 60).to_i
    hours, mins = total_min.divmod(60)
    days, hrs   = hours.divmod(24)

    parts = []
    parts << "#{days}d" if days > 0
    parts << "#{hrs}h"  if hrs > 0
    parts << "#{mins}m" if mins > 0 || parts.empty?
    parts.join(" ")
  end
end
