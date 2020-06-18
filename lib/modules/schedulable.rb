# frozen_string_literal: true

require 'set'

module Schedulable
  class ValueError < StandardError; end

  RANGE_STEP = 100
  MIN_HOUR = 800
  MAX_HOUR = 2000

  # Schedule format: WEEKDAY HOUR without space or hyphens (-)
  #   Hyphens are incompatible with graphs
  #   ex: ['MON1600', 'TUE1200']
  #   Hours from 0800 to 2000
  #   Weekdays: MON, TUE, WED, THU, FRI, SAT, SUN
  SCHEDULE_FORMAT = /[A-Z]{3}\d{4}/.freeze

  def availability
    raise NoMethodError, "#{self} must implement availability"
  end

  def availability_with_tolerance(tolerance)
    return availability if tolerance.zero?

    availability.each_with_object(Set.new) do |schedule, extended_availability|
      schedule_range = build_schedule_range(schedule, tolerance)
      extended_availability.merge(schedule_range)
    end
  end

  def available?(schedule_code)
    raise ValueError unless schedule_code =~ SCHEDULE_FORMAT

    availability.include?(schedule_code)
  end

  private

  def valid?(schedule_code)
    schedule_code =~ SCHEDULE_FORMAT
  end

  def valid_availability?(availability)
    availability.all? { |schedule_code| valid?(schedule_code) }
  end

  def match_with_tolerance?(schedule_code:, tolerance:)
    schedule_range = build_schedule_range(schedule_code, tolerance)
    match_schedule_range?(schedule_range)
  end

  def build_schedule_range(schedule_code, tolerance)
    return [schedule_code] unless tolerance.positive?

    schedule_range(interpret_code(schedule_code), tolerance)
  end

  def schedule_range(schedule, tolerance)
    max_hr = correct_schedule(schedule[:hour] + tolerance * RANGE_STEP)
    min_hr = correct_schedule(schedule[:hour] - tolerance * RANGE_STEP)
    (min_hr..max_hr).step(RANGE_STEP).map { |h| schedule[:day] + "%04d" % h }
  end

  def interpret_code(schedule)
    {
      day: schedule[0..2],
      hour: schedule[3..-1].to_i
    }
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

  def match_schedule_range?(availability_range)
    availability_range.any? { |schedule| availability.include?(schedule) }
  end
end
