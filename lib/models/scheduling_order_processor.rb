# frozen_string_literal: true

require_relative 'assigner'
require_relative 'course_factory'

class SchedulingOrderProcessor
  DEFAULT_TOLERANCE = 0
  DEFAULT_COURSE_SIZE = 6

  def initialize(scheduling_order)
    @scheduling_order = scheduling_order
  end

  def process(students:, teachers:, scheduled_courses:)
    return puts 'No type specified' if @scheduling_order[:student_type].nil?
    return puts 'No level specified' if @scheduling_order[:level].nil?

    setup(
      students: students,
      teachers: teachers,
      scheduled_courses: scheduled_courses
    )
    schedule_courses_and_reset_students
  end

  private

  def setup(students:, teachers:, scheduled_courses:)
    selected_students = select_students(students)
    mark_students_as_processed(students: students, selected: selected_students)
    create_assigner(students: selected_students, teachers: teachers)
    create_course_factory(
      students: students,
      teachers: teachers,
      courses_container: scheduled_courses
    )
  end

  def select_students(students)
    students.select do |_, student_element|
      !student_element[:processed] &&
        student_element[:student].in_scheduling_order?(@scheduling_order)
    end
  end

  def mark_students_as_processed(students:, selected:)
    selected.each do |id, _|
      students[id][:processed] = true
    end
  end

  def create_assigner(students:, teachers:)
    @assigner = Assigner.new(
      students: students,
      teachers: teachers,
      course_size: correct_course_size,
      tolerance: @scheduling_order[:tolerance].to_i || 0
    )
  end

  def correct_course_size
    size = @scheduling_order[:course_size]
    return size.to_i if size.to_i.positive?

    DEFAULT_COURSE_SIZE
  rescue NoMethodError
    DEFAULT_COURSE_SIZE
  end

  def create_course_factory(students:, teachers:, courses_container:)
    @course_factory = CourseFactory.new(
      students: students,
      teachers: teachers,
      course_size: correct_course_size,
      courses_container: courses_container
    )
  end

  def schedule_courses_and_reset_students
    assign_orders = @assigner.assign_orders
    @course_factory.manufacture_from(assign_orders) if assign_orders
  end
end
