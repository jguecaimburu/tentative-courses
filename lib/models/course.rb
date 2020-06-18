# frozen_sting_literal: true

require_relative 'course_group'
class Course
  class ValueError < StandardError; end

  STATUS = {
    CONFIRMED: 4,
    NOT_CONFIRMED: 1
  }.freeze

  attr_reader :id, :schedule, :level, :status, :rejected_students

  def initialize(details)
    raise TypeError, 'id missing' if details[:id].nil?
    raise TypeError, 'schedule missing' if details[:schedule].nil?
    raise TypeError, 'level missing' if details[:level].nil?
    raise TypeError, 'teacher missing' if details[:teacher].nil?

    build_from(details)
  end

  def confirmed?
    @teacher[:status] == STATUS[:CONFIRMED] && @group.confirmed?
  end

  def size_at_least?(int)
    @group.size_at_least?(int)
  end

  def add_students(students)
    return nil if students.nil?

    @rejected_students = []

    students.each do |student|
      @rejected_students << student unless @group.add_student(student)
    end
  end

  private

  def build_from(details)
    @teacher = add_teacher(details)
    @id = details[:id]
    @level = details[:level]
    @schedule = details[:schedule]
    @group = CourseGroup.new(course: self)
    @status = STATUS[:NOT_CONFIRMED]

    process_optional(details)
  end

  def add_teacher(details)
    validate_teacher_details(details)
    @teacher = {
      id: details[:teacher].id,
      teacher: details[:teacher],
      status: STATUS[:NOT_CONFIRMED]
    }
    assign_teacher
  end

  def validate_teacher_details(details)
    details[:teacher].teacher?
    teacher = details[:teacher]
    raise ValueError unless teacher.available?(details[:schedule])
    raise ValueError unless teacher.level?(details[:level])
    raise ValueError if teacher.full_assigned?
  rescue NoMethodError
    puts "#{details[:teacher]} is not a teacher"
    raise
  end

  def assign_teacher
    @teacher[:teacher].assign_course(self)
  end

  def process_optional(details)
    @group.config_size(details[:size])
    add_students(details[:students])
  end
end
