class Clock
  def initialize(hour, minute, ampm)
    @hour   = hour
    @minute = minute
    @ampm   = ampm
  end
  
  def minute_to_s
    if @minute < 10
      "0#{@minute}"
    else
      @minute
    end
  end
  
  def time_to_s
    "#{@hour}:#{minute_to_s} #{@ampm}"
  end
  
  def inspect
    "<Clock: #{time_to_s} >"
  end
  
  def toggle_ampm!
    if @ampm == 'pm'
      @ampm = 'am'
    else
      @ampm = 'pm'
    end
  end
  
  def add_1_hour!
    if @hour == 12
      toggle_ampm!
    end
    @hour = @hour + 1
  end
  
  def add_1_minute!
    if @minute == 59
      add_1_hour!
      @minute = 0
    else
      @minute = @minute + 1
    end
  end
  
  def add_n_minutes!(n)
    n.times do
      add_1_minute!
    end
  end
end
