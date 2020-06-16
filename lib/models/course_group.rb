# frozen_string_literal: true

class CourseGroup
  STUDENT_STATUS = {
    CONFIRMED: 4,
    WAITING_MATCH: 3,
    WAITING_UNMATCH: 2
  }.freeze
  DEFAULT_SIZE = 6

  attr_reader :type, :max_size

  def initialize(course:, students: [])
    @course = course
    @max_size = DEFAULT_SIZE
    @students = {}
    students.respond_to?(:each) ? add_students(students) : nil
  end

  def add_students(students)
    return nil if students.nil?
    return puts 'Course is full' if full?

    students.each do |student|
      add_student(student)
    end
  end

  def confirmed?
    @students.all? do |id, _|
      @students[id][:status] == STUDENT_STATUS[:CONFIRMED]
    end
  end

  def config_size(new_size = nil)
    return @max_size = 1 if new_size == 1

    new_size ||= DEFAULT_SIZE
    return @max_size = new_size.to_i if @max_size == 1 ||
                                        @max_size == DEFAULT_SIZE
  end

  def size_at_least?(int)
    @students.size >= int
  end

  private

  def full?
    @students.size == @max_size
  end

  def add_student(student)
    student.student?
    return puts 'Course is full' if full?

    try_to_add_student(student)
  rescue NoMethodError
    puts "#{student} is not a student. Not added"
  end

  def try_to_add_student(student)
    configure_type_and_size_if_first_student(student)
    add_student_if_type_match(student)
  end

  def configure_type_and_size_if_first_student(student)
    return nil unless @students.empty?
    return nil unless student.level?(@course.level)

    @type = student.type
    student.type?('INDIVIDUAL') ? config_size(1) : config_size
  end

  def add_student_if_type_match(student)
    return nil unless student.type?(@type)
    return nil unless student.level?(@course.level)
    return nil unless @students[student.id].nil?

    @students[student.id] = {
      student: student,
      status: match_schedule_status(student)
    }
  end

  def match_schedule_status(schedulable)
    if schedulable.available?(@course.schedule)
      STUDENT_STATUS[:WAITING_MATCH]
    else
      STUDENT_STATUS[:WAITING_UNMATCH]
    end
  end
end
