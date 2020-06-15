# frozen_string_literal: true

module Schedulable
  class ValueError < StandardError; end

  RANGE_STEP = 100
  MIN_HOUR = 800
  MAX_HOUR = 2000
  SCHEDULE_FORMAT = /[A-Z]{3}-\d{4}/.freeze

  def availability
    raise NoMethodError, "#{self} must implement availability"
  end

  def available?(schedule)
    raise ValueError unless schedule =~ SCHEDULE_FORMAT

    availability.include?(schedule)
  end

  private

  def valid?(schedule)
    schedule =~ SCHEDULE_FORMAT
  end

  def valid_availability?(availability)
    availability.all? { |schedule| valid?(schedule) }
  end

  def match_with_tolerance(schedule:, tolerance:)
    availability_range = build_availability_range(schedule, tolerance)
    match_availability_range?(availability_range)
  end

  def build_availability_range(schedule, tolerance)
    return [schedule] unless tolerance.positive?

    day = schedule[0..2]
    hour = schedule[3..-1].to_i
    max_hour = correct_schedule(hour + tolerance * RANGE_STEP)
    min_hour = correct_schedule(hour - tolerance * RANGE_STEP)
    (min_hour..max_hour).step(RANGE_STEP).map { |h| day + "%04d" % h }
  end

  def correct_schedule(hour)
    if hour < MIN_HOUR
      MIN_HOUR
    elsif hour > MAX_HOUR
      MAX_HOUR
    else
      hour
    end
  end

  def match_availability_range?(availability_range)
    availability_range.any? { |schedule| availability.include?(schedule) }
  end
end
