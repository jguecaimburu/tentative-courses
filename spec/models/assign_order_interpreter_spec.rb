# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/assign_order_interpreter'
require_relative 'shared_context'

RSpec.shared_context 'assign order interpreter' do
  before do
    @interpreter = AssignOrderInterpreter.new(
      students: {
        @group_student.id => {
          student: @group_student,
          processed: false
        },
        @other_group_student.id => {
          student: @other_group_student,
          processed: false
        }
      },
      teachers: {
        @teacher.id => {
          teacher: @teacher
        }
      },
      course_size: 6
    )
    @low_size_interpreter = AssignOrderInterpreter.new(
      students: {
        @group_student.id => {
          student: @group_student,
          processed: false
        },
        @other_group_student.id => {
          student: @other_group_student,
          processed: false
        }
      },
      teachers: {
        @teacher.id => {
          teacher: @teacher
        }
      },
      course_size: 1
    )
  end

  let(:assign_orders) do
    {
      'UNSOLVED' => { list: ['STUDENT KEYS'], flow: 1 },
      'TC1.INT-INTERMEDIATE-MON1500' => {
        list: ['ST4.GRU.INT', 'ST5.GRU.INT'],
        flow: 2
      },
      'TC1.INT-INTERMEDIATE-MON1600-ERROR' => { list: [], flow: 0 }
    }
  end
end

RSpec.describe AssignOrderInterpreter do
  include_context 'student instances'
  include_context 'teacher instances'
  include_context 'assign order interpreter'

  it 'translate only valid order' do
    expect(@interpreter.interpret(assign_orders).size).to eq(1)
  end

  it 'translates teacher correctly' do
    expect(
      @interpreter.interpret(assign_orders).all? do |_, interpretation|
        interpretation[:details][:teacher].teacher?
      end
    ).to be true
  end

  it 'translates students correctly' do
    expect(
      @interpreter.interpret(assign_orders).all? do |_, interpretation|
        interpretation[:details][:students].all?(&:student?)
      end
    ).to be true
  end

  it 'calculates valid remaining places' do
    expect(
      @interpreter.interpret(assign_orders).all? do |_, interpretation|
        interpretation[:remaining_places].positive?
      end
    ).to be true
  end

  it 'raises ValueError if any course order list is bigger than course size' do
    expect { @low_size_interpreter.interpret(assign_orders) }
      .to raise_error(AssignOrderInterpreter::ValueError)
  end
end
