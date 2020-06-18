# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/course_scheduler'
require_relative '../../lib/models/teacher'
require_relative '../../lib/models/student'

RSpec.shared_context 'basic course scheduler' do
  before do
    @teacher = Teacher.new(
      id: 'TC1.INT',
      availability: %w[MON1500 MON1600 TUE1600 WED1400],
      levels: %w[INTERMEDIATE ADVANCED UPPER_INTERMEDIATE],
      max_courses: 3
    )
    @single_course_teacher = Teacher.new(
      id: 'TC6.INT',
      availability: %w[MON1500 MON1600],
      levels: ['INTERMEDIATE'],
      max_courses: 1
    )
    @student = Student.new(
      id: 'ST1.IND.INT',
      type: 'INDIVIDUAL',
      level: 'INTERMEDIATE',
      availability: %w[MON1500 MON1700 TUE1600 FRI1400]
    )
    @individual_student = Student.new(
      id: 'ST2.IND.INT',
      type: 'INDIVIDUAL',
      level: 'INTERMEDIATE',
      availability: %w[MON1500 MON1600 TUE1600 WED1400]
    )
    @other_individual_student = Student.new(
      id: 'ST3.IND.INT',
      type: 'INDIVIDUAL',
      level: 'INTERMEDIATE',
      availability: %w[MON1500 MON1600 TUE1600 WED1400]
    )
    @group_student = Student.new(
      id: 'ST4.GRU.INT',
      type: 'GROUP',
      level: 'INTERMEDIATE',
      availability: %w[MON1500 MON1600 TUE1600 WED1400]
    )
    @other_group_student = Student.new(
      id: 'ST5.GRU.INT',
      type: 'GROUP',
      level: 'INTERMEDIATE',
      availability: %w[MON1500 MON1600 TUE1600 WED1400]
    )
  end

  let(:students) { [@group_student, @other_group_student] }
  let(:teachers) { [@teacher] }
  let(:individual_students) { [@individual_student, @other_individual_student] }
  let(:single_course_teacher) { [@single_course_teacher] }
end

RSpec.shared_context 'course scheduler' do
  before do
    @student_late = Student.new(
      id: 'STUDENT.LATE.GRU.UPPER',
      type: 'GROUP',
      level: 'UPPER_INTERMEDIATE',
      availability: %w[FRI2000]
    )
    @teacher_late = Teacher.new(
      id: 'TEACHER.LATE.TOLERANCE.UPPER',
      availability: %w[FRI1900],
      levels: %w[UPPER_INTERMEDIATE],
      max_courses: 1
    )
    @student_seven1 = Student.new(
      id: 'STUDENT.SEVEN.1.GRU.PRE',
      type: 'GROUP',
      level: 'PRE_INTERMEDIATE',
      availability: %w[THU2000]
    )
    @student_seven2 = Student.new(
      id: 'STUDENT.SEVEN.2.GRU.PRE',
      type: 'GROUP',
      level: 'PRE_INTERMEDIATE',
      availability: %w[THU2000]
    )
    @student_seven3 = Student.new(
      id: 'STUDENT.SEVEN.3.GRU.PRE',
      type: 'GROUP',
      level: 'PRE_INTERMEDIATE',
      availability: %w[THU2000]
    )
    @student_seven4 = Student.new(
      id: 'STUDENT.SEVEN.4.GRU.PRE',
      type: 'GROUP',
      level: 'PRE_INTERMEDIATE',
      availability: %w[THU2000]
    )
    @student_seven5 = Student.new(
      id: 'STUDENT.SEVEN.5.OUT.GRU.PRE',
      type: 'GROUP',
      level: 'PRE_INTERMEDIATE',
      availability: %w[THU2000],
      priority: 10
    )
    @student_seven6 = Student.new(
      id: 'STUDENT.SEVEN.6.GRU.PRE',
      type: 'GROUP',
      level: 'PRE_INTERMEDIATE',
      availability: %w[THU2000]
    )
    @student_seven7 = Student.new(
      id: 'STUDENT.SEVEN.7.GRU.PRE',
      type: 'GROUP',
      level: 'PRE_INTERMEDIATE',
      availability: %w[THU2000]
    )
    @teacher_seven = Teacher.new(
      id: 'TEACHER.SEVEN.PRE',
      availability: %w[THU2000],
      levels: %w[PRE_INTERMEDIATE],
      max_courses: 1
    )
    @student_options = Student.new(
      id: 'STUDENT.2.OPTIONS.IND.BEG',
      type: 'INDIVIDUAL',
      level: 'BEGINNER',
      availability: %w[MON0800]
    )
    @teacher_options_worst = Teacher.new(
      id: 'TEACHER.WORST.OPTIONS.BEG',
      availability: %w[MON0800],
      levels: %w[BEGINNER],
      max_courses: 1
    )
    @teacher_options_best = Teacher.new(
      id: 'TEACHER.BEST.OPTIONS.BEG',
      availability: %w[MON0800],
      levels: %w[BEGINNER],
      max_courses: 1,
      priority: 1
    )
  end

  let(:late_student) { [@student_late] }
  let(:late_teacher) { [@teacher_late] }
  let(:late_tolerance_order) do
    [{
      student_type: 'GROUP',
      level: 'UPPER_INTERMEDIATE',
      tolerance: 1
    }]
  end

  let(:seven_students) do
    [
      @student_seven1,
      @student_seven2,
      @student_seven3,
      @student_seven4,
      @student_seven5,
      @student_seven6,
      @student_seven7
    ]
  end
  let(:seven_teacher) { [@teacher_seven] }

  let(:options_student) { [@student_options] }
  let(:options_teachers) { [@teacher_options_best, @teacher_options_worst] }
end
