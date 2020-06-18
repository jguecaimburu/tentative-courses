# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/assigner'
require_relative 'shared_context'

RSpec.shared_context 'assigner' do
  let(:group_students) do
    {
      @group_student.id => {
        student: @group_student,
        processed: false
      },
      @other_group_student.id => {
        student: @other_group_student,
        processed: false
      }
    }
  end

  let(:individual_students) do
    {
      @individual_student.id => {
        student: @individual_student,
        processed: false
      },
      @other_individual_student.id => {
        student: @other_individual_student,
        processed: false
      }
    }
  end

  let(:different_days_students) do
    {
      @monday_student.id => {
        student: @monday_student,
        processed: false
      },
      @tuesday_student.id => {
        student: @tuesday_student,
        processed: false
      }
    }
  end

  let(:regular_teacher) { { @teacher.id => { teacher: @teacher } } }

  let(:different_days_teachers) do
    {
      @monday_teacher.id => {
        teacher: @monday_teacher
      },
      @tuesday_teacher.id => {
        teacher: @tuesday_teacher
      }
    }
  end
end

RSpec.describe Assigner do
  include_context 'student instances'
  include_context 'teacher instances'
  include_context 'assigner'

  it 'assigns group students to teacher' do
    assigner = Assigner.new(
      students: group_students,
      teachers: regular_teacher,
      course_size: 6,
      tolerance: 0
    )
    assign_orders = assigner.assign_orders
    total_flow = assign_orders.inject(0) do |sum, (_, assign_data)|
      sum + assign_data[:flow]
    end
    expect(total_flow).to eq(2)
  end

  it 'assigns individual students to different courses' do
    assigner = Assigner.new(
      students: individual_students,
      teachers: regular_teacher,
      course_size: 6,
      tolerance: 0
    )
    assign_orders = assigner.assign_orders
    total_flow = assign_orders.inject(0) do |sum, (_, assign_data)|
      sum + assign_data[:flow]
    end
    expect(total_flow).to eq(12)
    expect(assign_orders.size).to eq(2)
  end

  it 'assigns students to available teachers' do
    assigner = Assigner.new(
      students: different_days_students,
      teachers: different_days_teachers,
      course_size: 6,
      tolerance: 0
    )
    assign_orders = assigner.assign_orders
    total_flow = assign_orders.inject(0) do |sum, (_, assign_data)|
      sum + assign_data[:flow]
    end
    expect(total_flow).to eq(2)
    expect(assign_orders.size).to eq(2)
    expect(assign_orders.keys[0].split('-')[0])
      .not_to eq(assign_orders.keys[1].split('-')[0])
  end
end
