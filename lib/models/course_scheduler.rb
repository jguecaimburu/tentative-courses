# frozen_string_literal: true

require_relative 'scheduling_order_processor'

class CourseScheduler
  DEFAULT_TYPE_SCHEDULING_PRIORITIES = %w[GROUP INDIVIDUAL].freeze
  DEFAULT_LEVEL_SCHEDULING_PRIORITIES = %w[INTERMEDIATE UPPER_INTERMEDIATE
                                           PRE_INTERMEDIATE ADVANCED
                                           BEGINNER].freeze

  def initialize
    @students = {}
    @teachers = {}
    @scheduled_courses = []
  end

  def bulk_add_students(students)
    students.each { |student| add_student(student) }
  end

  def add_student(student)
    student.student?
    return nil unless @students[student.id].nil?

    @students[student.id] = {
      student: student,
      processed: false
    }
  rescue NoMethodError
    puts "#{student} is not a student. Not added"
  end

  def bulk_add_teachers(teachers)
    teachers.each { |teacher| add_teacher(teacher) }
  end

  def add_teacher(teacher)
    teacher.teacher?
    return nil unless @teachers[teacher.id].nil?

    @teachers[teacher.id] = {
      teacher: teacher
    }
  rescue NoMethodError
    puts "#{teacher} is not a teacher. Not added"
  end

  # Scheduling order format:
  # {
  #   student_type: 'INDIVIDUAL' or 'GROUP',
  #   level: valid student level
  #   tolerance (optional): Tolerance in hours for availability
  #   course_size (optional): Max number of students for groups
  # }

  def schedule_courses(scheduling_orders: [])
    return nil if @students.empty? || @teachers.empty?

    add_default_orders(scheduling_orders)
    until all_students_processed?
      process(scheduling_orders.shift)
      next unless scheduling_orders.empty?

      add_default_orders(scheduling_orders) unless all_students_processed?
    end
    @scheduled_courses
  end

  def unassigned_students
    @students.each_with_object([]) do |(_, student_element), unassigned|
      student = student_element[:student]
      unassigned << student unless student.assigned?
    end
  end

  private

  # Always process remaining unprocessed students in this order
  def add_default_orders(scheduling_orders)
    DEFAULT_TYPE_SCHEDULING_PRIORITIES.each do |type|
      DEFAULT_LEVEL_SCHEDULING_PRIORITIES.each do |level|
        scheduling_orders << { student_type: type, level: level}
      end
    end
  end

  def all_students_processed?
    @students.all? { |_, student| student[:processed] }
  end

  def process(scheduling_order)
    processor = SchedulingOrderProcessor.new(scheduling_order)
    processor.process(
      students: @students,
      teachers: @teachers,
      scheduled_courses: @scheduled_courses
    )
  end
end
