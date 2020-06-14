# frozen_string_literal: true

require_relative 'graph'
require_relative 'min_cost_max_flow_solver'

class Course_Scheduler
  def initialize
    @students = []
    @teachers = []
  end

  def bulk_add_students(students)
    students.each { |student| add_student(student) }
  end

  def add_student(student)
    student.student? && @students << student
  rescue NoMethodError
    puts "#{student} is not a student. Not added"
  end

  def bulk_add_teachers(teachers)
    teachers.each { |teacher| add_teacher(teacher) }
  end

  def add_teacher(teacher)
    teacher.teacher? && @teachers << teacher
  rescue NoMethodError
    puts "#{teacher} is not a teacher. Not added"
  end

  def schedule_courses(scheduling_orders: nil)
    return nil if @students.empty? || @teachers.empty?

    scheduling_orders ||= [{ student_type: nil, level: nil }]
    until scheduling_orders.empty?
      scheduling_order = scheduling_orders.shift
      process(scheduling_order)
    end
    # RETURN SOLUTION. MAYBE ADD READER TO INSTANCE VAR
  end

  private

  # REFACTOR
  def process(scheduling_order)
    # ADD TO GRAPH. SOLVER NEEDS TO CONFIRM IS SOLVER
    graph = build_graph()
    feed_graph(scheduling_order: scheduling_order, graph: graph)
    solution = solve(graph)
    # ADD THESE TO INSTANCE VARIABLE
    create_courses_from(solution)
  end

  def build_graph
    Graph.new.add_solver(Min_Cost_Max_Flow_Solver.new)
  end

  def feed_graph(scheduling_order:, graph:)
    graph_data = { nodes: {}, edges: {} }
    ask_individuals_to_build_graph_data(scheduling_order, graph_data)
  end

  def ask_individuals_to_build_graph_data(scheduling_order)
    # ask students for timetables
    # load sink to teachers
    # ask teachers to create edges and nodes for these timetables
    # load source to students
    # ask students to connect to course nodes and create its edges
  end

  def solve(graph)
    postprocess(solution)
  end

  def postprocess(solution)
  end






  # Should return courses and modify students and teachers. Separate confirmed from others


end
