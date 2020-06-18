# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/student'
require_relative '../../lib/models/teacher'

RSpec.shared_context 'student instances' do
  before do
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
    @third_group_student = Student.new(
      id: 'ST6.GRU.INT',
      type: 'GROUP',
      level: 'INTERMEDIATE',
      availability: %w[MON1500 MON1600 TUE1600 WED1400]
    )
    @beginner_group_student = Student.new(
      id: 'ST7.GRU.BEG',
      type: 'GROUP',
      level: 'BEGINNER',
      availability: %w[MON1500 MON1600 TUE1600 WED1400]
    )
    @monday_student = Student.new(
      id: 'ST8.GRU.INT',
      type: 'GROUP',
      level: 'INTERMEDIATE',
      availability: %w[MON1500 MON1600]
    )
    @tuesday_student = Student.new(
      id: 'ST9.GRU.INT',
      type: 'GROUP',
      level: 'INTERMEDIATE',
      availability: %w[TUE1500 TUE1600]
    )
  end
end

RSpec.shared_context 'teacher instances' do
  before do
    @teacher = Teacher.new(
      id: 'TC1.INT',
      availability: %w[MON1500 MON1600 TUE1600 WED1400],
      levels: %w[INTERMEDIATE ADVANCED UPPER_INTERMEDIATE],
      max_courses: 3
    )
    @other_teacher = Teacher.new(
      id: 'TC2.INT',
      availability: %w[MON1500 MON1600 TUE1600 WED1400],
      levels: %w[INTERMEDIATE ADVANCED UPPER_INTERMEDIATE],
      max_courses: 3
    )
    @beginner_teacher = Teacher.new(
      id: 'TC3.BEG',
      availability: %w[MON1500 MON1600 TUE1600 WED1400],
      levels: ['BEGINNER'],
      max_courses: 3
    )
    @monday_teacher = Teacher.new(
      id: 'TC4.INT',
      availability: %w[MON1500 MON1600],
      levels: ['INTERMEDIATE'],
      max_courses: 3
    )
    @tuesday_teacher = Teacher.new(
      id: 'TC5.INT',
      availability: %w[TUE1500 TUE1600],
      levels: ['INTERMEDIATE'],
      max_courses: 3
    )
    @single_course_teacher = Teacher.new(
      id: 'TC6.INT',
      availability: %w[MON1500 MON1600],
      levels: ['INTERMEDIATE'],
      max_courses: 1
    )
  end
end
