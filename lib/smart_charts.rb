module SmartCharts

  def self.selectTracker
    s = Hash.new
    Tracker.all.each do |tracker|
      s[tracker.name] = tracker.id
    end
    s
  end

end
