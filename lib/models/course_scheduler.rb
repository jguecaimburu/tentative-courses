# frozen_string_literal: true

require 'set'
require_relative 'assigner'

class CourseScheduler
  DEFAULT_TYPE_SCHEDULING_PRIORITIES = %w[GROUP INDIVIDUAL].freeze
  DEFAULT_LEVEL_SCHEDULING_PRIORITIES = %w[INTERMEDIATE UPPER-INTERMEDIATE
                                           PRE-INTERMEDIATE ADVANCED
                                           BEGINNER].freeze

  def initialize(course_size: 6)
    raise TypeError unless course_size.is_a? Integer

    @course_size = course_size
    @students = Set.new
    @teachers = Set.new
    @processed = {}
  end

  def bulk_add_students(students)
    students.each { |student| add_student(student) }
  end

  def add_student(student)
    if student.student?
      @processed[student.id].nil? && @processed[student.id] = false
      @students << student
    end
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

  # Scheduling order format:
  # {
  #   student_type: 'INDIVIDUAL' or 'GROUP',
  #   level: valid student level
  #   tolerance (optional): Tolerance in hours for availability
  # }
  def schedule_courses(scheduling_orders: [])
    return nil if @students.empty? || @teachers.empty?

    add_default_orders(scheduling_orders)
    until scheduling_orders.empty? || all_students_processed?
      scheduling_order = scheduling_orders.shift
      process(scheduling_order)
    end
    # RETURN SOLUTION. MAYBE ADD READER TO INSTANCE VAR
  end

  private

  def add_default_orders(scheduling_orders)
    DEFAULT_TYPE_SCHEDULING_PRIORITIES.each do |type|
      DEFAULT_LEVEL_SCHEDULING_PRIORITIES.each do |level|
        default_order = {
          student_type: type,
          level: level
        }
        scheduling_orders << default_order
      end
    end
  end

  def all_students_processed?
    @students.all? { |student| @processed[student.id] }
  end

  def process(scheduling_order)
    return puts 'No type specified' if scheduling_order[:student_type].nil?
    return puts 'No level specified' if scheduling_order[:level].nil?

    students_to_process = select_students_by(scheduling_order)
    assigner = Assigner.new(
      students: students_to_process,
      teachers: @teachers,
      course_size: @course_size,
      tolerance: scheduling_order[:tolerance]
    )
  end

  def select_students_by(scheduling_order)
    @students.select do |student|
      !@processed[student.id] && student.in_scheduling_order?(scheduling_order)
    end
  end



  # Should return courses and modify students and teachers. Separate confirmed from others


end
