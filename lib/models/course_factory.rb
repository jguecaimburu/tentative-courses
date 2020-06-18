# frozen_string_literal: true

require_relative 'course'
require_relative 'assign_order_interpreter'

class CourseFactory
  def initialize(students:, teachers:, course_size:, courses_container:)
    @students = students
    @teachers = teachers
    @course_size = course_size
    @courses_container = courses_container
    @scrap_students = []
  end

  def manufacture_from(assign_orders)
    interpreted_orders = interpret_orders(assign_orders)
    manufacture_full_courses(interpreted_orders)
    postprocess_remaining_orders(interpreted_orders)
    reset_scrap_students
  end

  private

  def interpret_orders(assign_orders)
    interpreter = AssignOrderInterpreter.new(
      students: @students,
      teachers: @teachers,
      course_size: @course_size
    )
    interpreter.interpret(assign_orders)
  end

  def manufacture_full_courses(interpreted_orders)
    initial_courses_ids = interpreted_orders.keys
    initial_courses_ids.each do |id|
      next unless interpreted_orders[id][:remaining_places].zero?

      manufacture_course(interpreted_orders[id][:details])
      interpreted_orders.delete(id)
    end
  end

  def manufacture_course(details)
    course = Course.new(details)
    @scrap_students += course.rejected_students
    @courses_container << course
  rescue Course::ValueError
    @scrap_students += details[:students]
    false
  end

  def postprocess_remaining_orders(interpreted_orders)
    initial_courses_ids = interpreted_orders.keys
    initial_courses_ids.each do |id|
      order = interpreted_orders[id]
      interpreted_orders.delete(id)
      find_a_match_and_try_to_merge(order, interpreted_orders)
      manufacture_course(order[:details])
    end
  end

  def find_a_match_and_try_to_merge(order, interpreted_orders)
    courses_ids = interpreted_orders.keys
    courses_ids.each do |other_id|
      next unless interpreted_orders[other_id]

      other_order = interpreted_orders[other_id]
      next unless match_to_merge?(order, other_order)

      interpreted_orders.delete(other_id)
      order = merge(order, other_order)
      break
    end
  end

  def match_to_merge?(order, other_order)
    return false unless match_details?(order[:details], other_order[:details])

    order[:remaining_places] == other_order[:current_size]
  end

  def match_details?(details, other_details)
    return false unless details[:level] == other_details[:level]

    details[:schedule] == other_details[:schedule]
  end

  def merge(order, other_order)
    order[:details][:students] += other_order[:details][:students]
    order
  end

  def reset_scrap_students
    @scrap_students.each do |student|
      @students[student.id][:processed] = false
    end
  end
end
