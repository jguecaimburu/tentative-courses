# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/student'

RSpec.shared_context 'student' do
  before do
    @student = Student.new(
      id: 1,
      type: 'INDIVIDUAL',
      level: 'INTERMEDIATE',
      availability: %w[MON-1500 MON-1600 TUE-1600 WED-1400]
    )
  end
end

RSpec.describe Student do
  include_context 'student'

  it 'affirm is a student when asked' do
    expect(@student.student?).to be true
  end

  it 'answer correctly about type' do
    expect(@student.type?('INDIVIDUAL')).to be true
    expect(@student.type?('GROUP')).to be false
  end

  it 'answer correctly about level' do
    expect(@student.level?('INTERMEDIATE')).to be true
    expect(@student.level?('ADVANCED')).to be false
  end

  it 'answer correctly about availability' do
    expect(@student.available?('MON-1500')).to be true
    expect(@student.available?('TUE-1500')).to be false
  end

  it 'raises ValueError if asked type is wrong' do
    expect { @student.type?('IND') }.to raise_error(Student::ValueError)
  end

  it 'raises ValueError if asked level is wrong' do
    expect { @student.level?('Inter') }.to raise_error(Student::ValueError)
  end

  it 'raises ValueError if asked schedule is wrong' do
    expect { @student.available?('Monday') }
      .to raise_error(Schedulable::ValueError)
  end

  it 'returns true if student is in scheduling order' do
    order = { student_type: 'INDIVIDUAL', level: 'INTERMEDIATE' }
    expect(@student.in_scheduling_order?(order)).to be true
  end

  it 'returns false if student is not in scheduling order' do
    order_group = { student_type: 'GROUP', level: 'INTERMEDIATE' }
    order_advanced = { student_type: 'INDIVIDUAL', level: 'ADVANCED' }
    expect(@student.in_scheduling_order?(order_group)).to be false
    expect(@student.in_scheduling_order?(order_advanced)).to be false
  end

  it 'returns true if scheduling order property is nil' do
    order_no_type = { level: 'INTERMEDIATE' }
    order_no_level = { student_type: 'INDIVIDUAL'}
    order_empty = {}
    expect(@student.in_scheduling_order?(order_no_level)).to be true
    expect(@student.in_scheduling_order?(order_no_type)).to be true
    expect(@student.in_scheduling_order?(order_empty)).to be true
  end
end
