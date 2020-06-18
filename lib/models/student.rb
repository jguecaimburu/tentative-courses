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
  STATUS = {
    NOT_ASSIGNED: 0,
    ASSIGNED_WITH_TOLERANCE: 1,
    ASSIGNED: 2,
    CONFIRMED: 3
  }.freeze

  PRINTABLE_STATUS = {
    0 => 'Not Assigned',
    1 => 'Assigned with tolerance',
    2 => 'Assigned',
    3 => 'Confirmed'
  }.freeze

  # id: Can't use hyphens (-)
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
    setup
  end

  def to_s
    "Student #{@id}. Type: #{@type}. Level: #{@level}. \
Status: #{PRINTABLE_STATUS[@course_group[:status]]}."
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
    add_own_edge_to_hight_cost_link(edge_data)
    add_edges_to_link_nodes(edge_data)
  end

  def assigned?
    @course_group[:status] != STATUS[:NOT_ASSIGNED]
  end

  def assign_course_group(course_group)
    return false if assigned?

    @course_group[:group] = course_group
    change_status_to_assigned
  end

  private

  def setup
    @course_group = { status: STATUS[:NOT_ASSIGNED], group: nil }
  end

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

  def change_status_to_assigned
    @course_group[:status] = STATUS[:ASSIGNED]
    return nil if available?(@course_group[:group].course_details[:schedule])

    @course_group[:status] = STATUS[:ASSIGNED_WITH_TOLERANCE]
  end
end
