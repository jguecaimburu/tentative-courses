# frozen_string_literal: true

class AssignOrderInterpreter
  class ValueError < StandardError; end

  UNSOLVED_TRANSLATED_KEY = 'UNSOLVED'

  def initialize(students:, teachers:, course_size:)
    @students = students
    @teachers = teachers
    @course_size = course_size
  end

  def interpret(assign_orders)
    assign_orders.each_with_object({}) do |order, interpretations|
      next if order[0] == UNSOLVED_TRANSLATED_KEY
      next if order[1][:list].empty?
      next unless interpretations[order[0]].nil?

      interpretations[order[0]] = build_interpretation(
        code: order[0],
        students_data: order[1]
      )
    end
  end

  private

  def build_interpretation(code:, students_data:)
    code_interpretation = interpret_course_code(code)
    data_interpretation = interpret_data(students_data)
    details = build_course_details(code_interpretation, data_interpretation)
    {
      current_size: data_interpretation[:current_size],
      remaining_places: data_interpretation[:remaining_places],
      details: details
    }
  end

  def interpret_course_code(code)
    {
      id: code,
      teacher: @teachers[code.split('-')[0]][:teacher],
      schedule: code.split('-')[2],
      level: code.split('-')[1]
    }
  end

  def interpret_data(students_data)
    {
      current_size: students_data[:flow],
      remaining_places: remaining_places(students_data[:flow]),
      students: list_students(students_data[:list])
    }
  end

  def remaining_places(students_count)
    raise ValueError unless students_count <= @course_size

    @course_size - students_count
  end

  def list_students(students_id_list)
    students_id_list.map { |id| @students[id][:student] }
  end

  def build_course_details(code_interpretation, data_interpretation)
    {
      id: code_interpretation[:id],
      teacher: code_interpretation[:teacher],
      schedule: code_interpretation[:schedule],
      level: code_interpretation[:level],
      students: data_interpretation[:students]
    }
  end
end
