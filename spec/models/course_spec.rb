# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/course'
require_relative 'shared_context'

RSpec.shared_context 'course' do
  let(:details_basic) do
    {
      id: 'COURSE_ID_1',
      level: 'INTERMEDIATE',
      schedule: 'MON1500',
      teacher: @teacher
    }
  end

  let(:teacher_first_course) do
    {
      id: 'COURSE_ID_2',
      level: 'INTERMEDIATE',
      schedule: 'MON1500',
      teacher: @single_course_teacher
    }
  end

  let(:teacher_second_course) do
    {
      id: 'COURSE_ID_3',
      level: 'INTERMEDIATE',
      schedule: 'MON1600',
      teacher: @single_course_teacher
    }
  end

  let(:details_with_student) do
    {
      id: 'COURSE_ID_4',
      level: 'INTERMEDIATE',
      schedule: 'MON1500',
      teacher: @teacher,
      students: [@group_student]
    }
  end

  let(:details_other_with_student) do
    {
      id: 'COURSE_ID_5',
      level: 'INTERMEDIATE',
      schedule: 'MON1500',
      teacher: @other_teacher,
      students: [@other_group_student]
    }
  end

  let(:details_students_of_diff_types) do
    {
      id: 'COURSE_ID_6',
      level: 'INTERMEDIATE',
      schedule: 'MON1500',
      teacher: @other_teacher,
      students: [@group_student, @individual_student, @other_group_student]
    }
  end

  let(:details_missing) do
    {
      id: 'COURSE_ID_7',
      level: 'INTERMEDIATE',
      teacher: @other_teacher
    }
  end

  let(:details_incompatible_teacher) do
    {
      id: 'COURSE_ID_8',
      level: 'INTERMEDIATE',
      schedule: 'MON1500',
      teacher: @beginner_teacher
    }
  end
end

RSpec.describe Course do
  include_context 'course'
  include_context 'student instances'
  include_context 'teacher instances'

  it 'creates empty course' do
    course = Course.new(details_basic)
    expect(course.size_at_least?(0)).to be true
    expect(course.size_at_least?(1)).to be false
  end

  it 'creates course with 1 student' do
    course = Course.new(details_with_student)
    expect(course.size_at_least?(0)).to be true
    expect(course.size_at_least?(1)).to be true
    expect(course.size_at_least?(2)).to be false
  end

  it 'creates course of same type students' do
    course = Course.new(details_students_of_diff_types)
    expect(course.size_at_least?(2)).to be true
    expect(course.size_at_least?(3)).to be false
  end

  it 'raises TypeError on missing values' do
    expect { Course.new(details_missing) }.to raise_error(TypeError)
  end

  it 'raises ValueError on incompatible teacher' do
    expect { Course.new(details_incompatible_teacher) }
      .to raise_error(Course::ValueError)
  end

  it 'blocks course schedulo on teacher if successfully assigned' do
    course = Course.new(details_basic)
    expect(@teacher.available?(course.schedule)).to be false
  end

  it 'does not assign course to teacher on fail' do
    expect { Course.new(details_incompatible_teacher) }
      .to raise_error(Course::ValueError)
    expect(
      @beginner_teacher.available?(details_incompatible_teacher[:schedule])
    ).to be true
  end

  it 'raises value error on full teacher' do
    expect(Course.new(teacher_first_course)).to be_truthy
    expect { Course.new(teacher_second_course) }
      .to raise_error(Course::ValueError)
  end

  it 'return rejected students' do
    course = Course.new(details_students_of_diff_types)
    rejected_students = course.rejected_students
    expect(rejected_students.size).to eq(1)
    expect(rejected_students.first.student?).to be true
  end
end
