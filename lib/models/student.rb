# frozen_string_literal: true

require_relative '../modules/graphable'
require_relative '../modules/schedulable'

class Student
  include Graphable
  include Schedulable

  class ValueError < StandardError; end

  attr_reader :id, :availability, :level, :type

  TYPES = %w[INDIVIDUAL GROUP].freeze
  LEVELS = %w[BEGINNER PRE_INTERMEDIATE INTERMEDIATE
              UPPER_INTERMEDIATE ADVANCED].freeze

  # availability: array of strings representing weekday-hour in
  # schedulable format

  def initialize(id:, type:, availability:, level:, priority: 5)
    raise ValueError unless TYPES.include?(type) && LEVELS.include?(level)
    raise ValueError unless valid_availability?(availability)
    raise TypeError unless priority.is_a? Integer

    @id = id
    @type = type
    @availability = availability
    @level = level
    @priority = priority
  end

  def to_s
    puts "Student #{@id}. Type: #{@type}. Level: #{@level}"
  end

  def eql?(other)
    @id == other.id
  end

  def hash
    @id.hash
  end

  def student?
    true
  end

  def type?(type)
    raise ValueError unless TYPES.include?(type)

    @type == type
  end

  def level?(level)
    raise ValueError unless LEVELS.include?(level)

    @level == level
  end

  def in_scheduling_order?(scheduling_order)
    scheduling_type = scheduling_order[:student_type]
    scheduling_level = scheduling_order[:level]
    is_type = scheduling_type ? type?(scheduling_type) : true
    is_level = scheduling_level ? level?(scheduling_level) : true
    is_type && is_level
  end

  def build_graph_data(graph_data:, course_size:, tolerance: 0)
    edge_data = {
      graph_data: graph_data,
      capacity: type?('GROUP') ? 1 : course_size,
      cost: @priority
    }
    @tolerance = tolerance
    add_own_edge_from_source(edge_data)
    add_edges_to_link_nodes(edge_data)
  end

  private

  def match_node?(course_node)
    node_interpretation = interpret_node_id(course_node)
    match_with_tolerance?(
      schedule_code: node_interpretation[:schedule],
      tolerance: @tolerance
    ) && level?(node_interpretation[:level])
  end

  def interpret_node_id(course_node)
    {
      schedule: course_node.split('-')[2],
      level: course_node.split('-')[1]
    }
  end
end
