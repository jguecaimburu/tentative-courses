# frozen_string_literal: true

require_relative 'graph'
require_relative 'min_cost_max_flow_solver'
require_relative 'max_flow_translator'
require_relative '../modules/graphable'

class Assigner
  include Graphable

  def initialize(students:, teachers:, course_size:, tolerance:)
    @students = students
    @teachers = teachers
    @course_size = course_size
    @tolerance = tolerance
    @graph_data = build_graph_data_holder
  end

  def assign_orders
    return nil if @students.empty? || @teachers.empty?

    graph = build_graph
    feed_graph(graph)
    solution = solve(graph)
    translate(solution)
  end

  private

  def build_graph
    Graph.new.add_solver(MinCostMaxFlowSolver.new)
  end

  def feed_graph(graph)
    ask_individuals_to_fill_data
    add_edge_from_hight_cost_link_to_sink(graph_data: @graph_data)
    graph.bulk_add_edges(@graph_data[:edges])
    graph.sink_key = @graph_data[:sink_key]
    graph.source_key = @graph_data[:source_key]
  end

  def ask_individuals_to_fill_data
    ask_teachers_data(students_requirements)
    ask_students_data
  end

  def students_requirements
    requirements = { levels: Set.new, availability: Set.new }
    @students.each_with_object(requirements) do |std_element, req|
      req[:levels] << std_element[1][:student].level
      req[:availability].merge(
        std_element[1][:student].availability_with_tolerance(@tolerance)
      )
    end
  end

  def ask_teachers_data(students_requirements)
    @teachers.each do |_, teacher_element|
      teacher_element[:teacher].build_graph_data(
        graph_data: @graph_data,
        course_size: @course_size,
        students_requirements: students_requirements
      )
    end
  end

  def ask_students_data
    @students.each do |_, student_element|
      student_element[:student].build_graph_data(
        graph_data: @graph_data,
        course_size: @course_size,
        tolerance: @tolerance
      )
    end
  end

  def solve(graph)
    graph.solve
  end

  def translate(solution)
    MaxFlowTranslator.new(origin_nodes: @students).translate(solution)
  end
end
