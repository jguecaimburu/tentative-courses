# frozen_string_literal: true

require 'json'

require 'rspec'
require_relative 'shared_context'
require_relative '../../lib/models/course_factory'

RSpec.shared_context 'course factory' do
  let(:students) do
    {
      @group_student.id => {
        student: @group_student,
        processed: true
      },
      @other_group_student.id => {
        student: @other_group_student,
        processed: true
      }
    }
  end

  let(:individual_students) do
    {
      @individual_student.id => {
        student: @individual_student,
        processed: true
      },
      @other_individual_student.id => {
        student: @other_individual_student,
        processed: true
      }
    }
  end

  let(:teachers) { { @teacher.id => { teacher: @teacher } } }

  let(:single_course_teacher) do
    { @single_course_teacher.id => { teacher: @single_course_teacher } }
  end

  let(:assign_orders) do
    {
      'TC1.INT-INTERMEDIATE-MON1500' => {
        list: ['ST4.GRU.INT', 'ST5.GRU.INT'],
        flow: 2
      }
    }
  end

  let(:one_valid_one_invalid) do
    {
      'TC6.INT-INTERMEDIATE-MON1500' => {
        list: ['ST2.IND.INT'],
        flow: 6
      },
      'TC6.INT-INTERMEDIATE-MON1600' => {
        list: ['ST3.IND.INT'],
        flow: 6
      }
    }
  end
end

RSpec.describe CourseFactory do
  include_context 'student instances'
  include_context 'teacher instances'
  include_context 'course factory'

  it 'creates course for order' do
    container = []
    factory = CourseFactory.new(
      students: students,
      teachers: teachers,
      course_size: 6,
      courses_container: container
    )
    factory.manufacture_from(assign_orders)
    expect(container.size).to eq(assign_orders.size)
    expect(
      students.all? do |_, student_element|
        student_element[:student].assigned? &&
          student_element[:processed]
      end
    ).to be true
  end

  it 'rejects order if teacher gets full before' do
    container = []
    factory = CourseFactory.new(
      students: individual_students,
      teachers: single_course_teacher,
      course_size: 6,
      courses_container: container
    )
    factory.manufacture_from(one_valid_one_invalid)
    expect(container.size).to eq(1)
    expect(
      individual_students.one? do |_, student_element|
        student_element[:student].assigned? &&
          student_element[:processed]
      end
    ).to be true
  end
end
