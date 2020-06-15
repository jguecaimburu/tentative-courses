# frozen_string_literal: true

require_relative 'graph'
require_relative 'min_cost_max_flow_solver'

class Assigner
  def initialize(students:, teachers:, course_size:, tolerance:)
    tolerance ||= 0
    raise TypeError unless tolerance&.to_i?

    @students = students
    @teachers = teachers
    @course_size = course_size
    @tolerance = tolerance
    @courses_proposal = []
    @graph_data = build_graph_data_holder
  end

  def assign
    fill_courses_proposal
    @courses_proposal
  end

  private

  def build_graph_data_holder
    {
      edges: [],
      nodes: [],
      source_key: 'SOURCE' + Time.now.to_i.to_s,
      sink_key: 'SINK' + Time.now.to_i.to_s
    }
  end

  def fill_courses_proposal
    graph = build_graph
    feed_graph(graph)
    solution = solve(graph)
    create_courses_from(solution)
  end

  def build_graph
    Graph.new.add_solver(MinCostMaxFlowSolver.new)
  end

  def feed_graph(graph:)
    ask_individuals_to_fill_data
    graph.bulk_add_edges(@graph_data[:edges])
    graph.source_key = @graph_data[:source_key]
    graph.sink_key = @graph_data[:sink_key]
  end

  def ask_individuals_to_fill_data
    ask_teachers_data(students_requirements)
    ask_students_data
  end

  def student_requirements
    requirements = { levels: Set.new, availability: Set.new }
    @students.each_with_object(requirements) do |student, req|
      req[:levels] << student.level
      req[:availability].merge(student.availability)
    end
  end

  def ask_teachers_data(students_requirements)
    @teachers.each do |teacher|
      teacher.build_graph_data(
        graph_data: @graph_data,
        course_size: @course_size,
        students_requirements: students_requirements
      )
    end
  end

  def ask_students_data
    @students.each do |student|
      student.build_graph_data(
        graph_data: @graph_data,
        course_size: @course_size,
        tolerance: @tolerance
      )
    end
  end
  # mark students as processed

  def solve(graph)
    flow_solution = graph.solve
  end
end
