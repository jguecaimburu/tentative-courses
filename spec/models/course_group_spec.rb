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
    students = [@group_student, @other_group_student]
    students.each { |student| @empty_group.add_student(student) }
    expect(@empty_group.size_at_least?(1)).to be true
    expect(@empty_group.size_at_least?(2)).to be true
  end

  it 'adds only one time the same student' do
    students = [@group_student, @group_student]
    students.each { |student| @empty_group.add_student(student) }
    expect(@empty_group.size_at_least?(1)).to be true
    expect(@empty_group.size_at_least?(2)).to be false
  end

  it 'rejects second student if first is individual' do
    students = [@individual_student, @student]
    students.each { |student| @empty_group.add_student(student) }
    expect(@empty_group.size_at_least?(1)).to be true
    expect(@empty_group.size_at_least?(2)).to be false
  end

  it 'overwrites size if a value was set but individual student is added' do
    @empty_group.config_size(4)
    students = [@individual_student]
    students.each { |student| @empty_group.add_student(student) }
    expect(@empty_group.max_size).to eq(1)
  end

  it 'overwrites size to default if 1 was set but group student is added' do
    @empty_group.config_size(1)
    students = [@group_student]
    students.each { |student| @empty_group.add_student(student) }
    expect(@empty_group.max_size).to eq(6)
  end

  it 'respect config size if group' do
    @empty_group.config_size(2)
    students = [
      @group_student,
      @other_group_student,
      @third_group_student
    ]
    students.each { |student| @empty_group.add_student(student) }
    expect(@empty_group.max_size).to eq(2)
    expect(@empty_group.size_at_least?(3)).to be false
    expect(@empty_group.size_at_least?(2)).to be true
  end

  it 'adds only the student that match level' do
    students = [@group_student, @beginner_group_student]
    students.each { |student| @empty_group.add_student(student) }
    expect(@empty_group.size_at_least?(1)).to be true
    expect(@empty_group.size_at_least?(2)).to be false
  end

  it 'adds students that match course as unconfirmed' do
    students = [@group_student, @other_group_student]
    students.each { |student| @empty_group.add_student(student) }
    expect(@empty_group.confirmed?).to be false
  end

  it 'change student assigned status on success' do
    expect(@group_student.assigned?).to be false
    @empty_group.add_student(@group_student)
    expect(@group_student.assigned?).to be true
  end

  it 'does not change assigned status on rejected student' do
    expect(@student.assigned?).to be false
    students = [@individual_student, @student]
    students.each { |student| @empty_group.add_student(student) }
    expect(@student.assigned?).to be false
  end
end
