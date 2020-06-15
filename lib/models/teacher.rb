# frozen_string_literal: true

require 'set'
require_relative '../modules/graphable'

class Teacher
  include Graphable

  class ValueError < StandardError; end

  attr_reader :id, :availability

  LEVELS = %w[BEGINNER PRE_INTERMEDIATE INTERMEDIATE
              UPPER_INTERMEDIATE ADVANCED].freeze
  SCHEDULE_FORMAT = /[A-Z]{3}\d{4}/.freeze

  # availability: array of strings representing weekday-hour in
  # schedulable format
  def initialize(id:, availability:, levels:, max_courses:, priority: 5)
    raise ValueError unless levels.all? { |level| LEVELS.include?(level) }
    raise ValueError unless availability.all?{|sched| sched =~ SCHEDULE_FORMAT}
    raise TypeError unless max_courses.is_a? Integer
    raise TypeError unless priority.is_a? Integer

    @id = id
    @availability = availability
    @levels = levels
    @max_courses = max_courses
    @priority = priority
  end

  def to_s
    puts "Teacher #{@id}."
  end

  def eql?(other)
    @id == other.id
  end

  def hash
    @id.hash
  end

  def teacher?
    true
  end

  def build_graph_data(graph_data:, course_size:, student_requirements:)
    add_own_edge_to_sink(
      graph_data: graph_data,
      capacity: @max_courses * course_size,
      cost: @priority
    )
    add_courses_data(
      graph_data: graph_data,
      matched_requirements: match_requirements(student_requirements),
      course_size: course_size
    )
  end

  private

  def match_requirements(student_requirements)
    {
      levels: student_requirements[:levels] & Set.new(@levels),
      availability: student_requirements[:availability] & Set.new(@availability)
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
end
