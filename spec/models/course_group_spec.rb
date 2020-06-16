# frozen_string_literal: true

require 'rspec'
require 'ostruct'
require_relative '../../lib/models/course_group'
require_relative 'shared_context'

RSpec.shared_context 'course group' do
  before do
    @empty_group = CourseGroup.new(
      course: OpenStruct.new(
        level: 'INTERMEDIATE',
        schedule: 'MON1500'
      )
    )
  end
end

RSpec.describe CourseGroup do
  include_context 'course group'
  include_context 'student instances'

  it 'adds students that match course' do
    @empty_group.add_students([@group_student, @other_group_student])
    expect(@empty_group.size_at_least?(1)).to be true
    expect(@empty_group.size_at_least?(2)).to be true
  end

  it 'adds only one time the same student' do
    @empty_group.add_students([@group_student, @group_student])
    expect(@empty_group.size_at_least?(1)).to be true
    expect(@empty_group.size_at_least?(2)).to be false
  end

  it 'rejects second student if first is individual' do
    @empty_group.add_students([@individual_student, @student])
    expect(@empty_group.size_at_least?(1)).to be true
    expect(@empty_group.size_at_least?(2)).to be false
  end

  it 'overwrites size if a value was set but individual student is added' do
    @empty_group.config_size(4)
    @empty_group.add_students([@individual_student])
    expect(@empty_group.max_size).to eq(1)
  end

  it 'overwrites size to default if 1 was set but group student is added' do
    @empty_group.config_size(1)
    @empty_group.add_students([@group_student])
    expect(@empty_group.max_size).to eq(6)
  end

  it 'respect config size if group' do
    @empty_group.config_size(2)
    @empty_group.add_students(
      [
        @group_student,
        @other_group_student,
        @third_group_student
      ]
    )
    expect(@empty_group.max_size).to eq(2)
    expect(@empty_group.size_at_least?(3)).to be false
    expect(@empty_group.size_at_least?(2)).to be true
  end

  it 'adds only the student that match level' do
    @empty_group.add_students([@group_student, @beginner_group_student])
    expect(@empty_group.size_at_least?(1)).to be true
    expect(@empty_group.size_at_least?(2)).to be false
  end

  it 'adds students that match course as unconfirmed' do
    @empty_group.add_students([@group_student, @other_group_student])
    expect(@empty_group.confirmed?).to be false
  end
end
