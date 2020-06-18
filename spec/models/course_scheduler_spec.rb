# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/course_scheduler'
require_relative 'shared_context'

RSpec.shared_context 'course scheduler' do
  let(:students) { [@group_student, @other_group_student] }
  let(:teachers) { [@teacher] }
  let(:individual_students) { [@individual_student, @other_individual_student] }
  let(:single_course_teacher) { [@single_course_teacher] }
end

RSpec.describe CourseScheduler do
  include_context 'course scheduler'
  include_context 'student instances'
  include_context 'teacher instances'

  it 'returns truthy value if student added correctly' do
    expect(CourseScheduler.new.add_student(@student)).to be_truthy
  end

  it 'returns truthy value if teacher added correctly' do
    expect(CourseScheduler.new.add_teacher(@teacher)).to be_truthy
  end

  it 'returns falsy value if teacher or student added incorrectly' do
    expect(CourseScheduler.new.add_teacher(@student)).to be_falsy
    expect(CourseScheduler.new.add_student(@teacher)).to be_falsy
  end

  it 'returns falsy value if no teachers or students were given yet' do
    expect(CourseScheduler.new.schedule_courses).to be_falsy
  end

  it 'creates courses' do
    course_scheduler = CourseScheduler.new
    course_scheduler.bulk_add_students(students)
    course_scheduler.bulk_add_teachers(teachers)
    courses = course_scheduler.schedule_courses

    expect(students.all?(&:assigned?)).to be true
    puts 'TEST PRINT'
    puts courses[0]
  end

  it 'rejects order if teacher gets full before' do
    course_scheduler = CourseScheduler.new
    course_scheduler.bulk_add_students(individual_students)
    course_scheduler.bulk_add_teachers(single_course_teacher)
    courses = course_scheduler.schedule_courses

    expect(courses.size).to eq(1)
    expect(individual_students.one?(&:assigned?)).to be true
  end
end
