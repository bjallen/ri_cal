module RiCal
  class PropertyValue
    # RiCal::PropertyValue::CalAddress represents an icalendar Duration property value
    # which is defined in 
    # rfc 2445 section 4.3.6 p 37
    class Duration < PropertyValue

      def self.value_part(unit, diff) # :nodoc:
        (diff == 0) ? nil : "#{diff}#{unit}"
      end

      def self.from_datetimes(start, finish, sign='+') # :nodoc:
        if start > finish
          from_datetimes(finish, start, '-')
        else
          diff = finish - start
          days_diff = diff.to_i
          hours = (diff - days_diff) * 24
          hour_diff = hours.to_i
          minutes = (hours - hour_diff) * 60
          min_diff = minutes.to_i
          seconds = (minutes - min_diff) * 60
          sec_diff = seconds.to_i

          day_part = value_part('D',days_diff)
          hour_part = value_part('H', hour_diff)
          min_part = value_part('M', min_diff)
          sec_part = value_part('S', sec_diff)
          new(:value => "#{sign}P#{day_part}T#{day_part}#{hour_part}#{min_part}#{sec_part}")        
        end
      end

      def self.convert(ruby_object) # :nodoc:
        ruby_object.to_ri_cal_duration_value
      end

      def value=(string) # :nodoc:
        super
        match = /([+-])?P(.*)$/.match(string)
        @days = @hours = @minutes = @seconds = @weeks = 0
        if match
          @sign = match[1] == '-' ? -1 : 1
          match[2].scan(/(\d+)([DHMSW])/) do |digits, unit|
            number = digits.to_i
            case unit
            when 'D'
              @days = number
            when 'H'
              @hours = number
            when 'M'
              @minutes = number
            when 'S'
              @seconds = number
            when 'W'
              @weeks = number
            end
          end
        end
      end

      def days # :nodoc:
        @days * @sign
      end

      def weeks # :nodoc:
        @weeks * @sign
      end

      def hours # :nodoc:
        @hours * @sign
      end

      def minutes # :nodoc:
        @minutes * @sign
      end

      def seconds # :nodoc:
        @seconds * @sign
      end

      # Determine whether another object is an equivalent RiCal::PropertyValue::Duration
      def ==(other)
        other.kind_of?(PropertyValue::Duration) && value == other.value
      end

      # Returns the receiver
      def to_ri_cal_duration_value
        self
      end

      # Double-dispatch method to support RiCal::PropertyValue::DateTime.-
      def subtract_from_date_time_value(date_time_value)
        date_time_value.advance(:weeks => -weeks, :days => -days, :hours => -hours, :minutes => -minutes, :seconds => -seconds)
      end

      # Double-dispatch method to support RiCal::PropertyValue::DateTime.+
      def add_to_date_time_value(date_time_value)
        date_time_value.advance(:weeks => weeks, :days => days, :hours => hours, :minutes => minutes, :seconds => seconds)
      end

    end
  end
end