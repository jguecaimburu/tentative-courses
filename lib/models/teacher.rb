# frozen_string_literal: true

require 'set'
require_relative '../modules/graphable'
require_relative '../modules/schedulable'

class Teacher
  include Graphable
  include Schedulable

  class ValueError < StandardError; end

  attr_reader :id, :availability

  LEVELS = %w[BEGINNER PRE_INTERMEDIATE INTERMEDIATE
              UPPER_INTERMEDIATE ADVANCED].freeze

  COURSE_STATUS = { ASSIGNED: 2, CONFIRMED: 3 }.freeze

  # id: Can't use hyphens (-)
  # availability: array of strings representing weekday-hour in
  # schedulable format
  def initialize(id:, availability:, levels:, max_courses:, priority: 5)
    raise ValueError unless levels.all? { |level| LEVELS.include?(level) }
    raise ValueError unless valid_availability?(availability)
    raise TypeError unless max_courses.is_a? Integer
    raise TypeError unless priority.is_a? Integer

    @id = id
    @availability = availability
    @levels = levels
    @max_courses = max_courses
    @priority = priority
    setup
  end

  def to_s
    "Teacher #{@id}."
  end

  def teacher?
    true
  end

  def level?(level)
    raise ValueError unless LEVELS.include?(level)

    @levels.include?(level)
  end

  def build_graph_data(graph_data:, course_size:, students_requirements:)
    add_own_edge_to_sink(
      graph_data: graph_data,
      capacity: @max_courses * course_size,
      cost: @priority
    )
    add_courses_data(
      graph_data: graph_data,
      matched_requirements: match_requirements(students_requirements),
      course_size: course_size
    )
  end

  def assign_course(course)
    return false if full_assigned?
    return false unless @courses[course.id].nil?

    @courses[course.id] = {
      course: course,
      status: COURSE_STATUS[:ASSIGNED]
    }
    block_assigned_schedule(course.schedule)
  end

  def full_assigned?
    (@max_courses - @confirmed_schedules.size - @assigned_schedules.size).zero?
  end

  private

  def setup
    @courses = {}
    @assigned_schedules = []
    @confirmed_schedules = []
  end

  def match_requirements(students_requirements)
    {
      levels: students_requirements[:levels] & Set.new(@levels),
      availability: students_requirements[:availability] & Set.new(@availability)
    }
  end

  def add_courses_data(graph_data:, matched_requirements:, course_size:)
    matched_requirements[:availability].each do |schedule|
      matched_requirements[:levels].each do |level|
        add_link_node_with_edge_from_it(
          graph_data: graph_data,
          node: "#{@id}-#{level}-#{schedule}",
          capacity: course_size,
          cost: @priority
        )
      end
    end
  end

  def block_assigned_schedule(schedule)
    @availability.delete(schedule)
    @assigned_schedules << schedule
  end
end
