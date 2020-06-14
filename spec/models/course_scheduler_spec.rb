# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/course_scheduler'
require_relative '../../lib/models/student'
require_relative '../../lib/models/teacher'

RSpec.describe Course_Scheduler do
  it 'returns truthy value if student added correctly' do
    student = Student.new
    expect(Course_Scheduler.new.add_student(student)).to be_truthy
  end

  it 'returns truthy value if teacher added correctly' do
    teacher = Teacher.new
    expect(Course_Scheduler.new.add_teacher(teacher)).to be_truthy
  end

  it 'returns falsy value if teacher or student added incorrectly' do
    student = Student.new
    teacher = Teacher.new
    expect(Course_Scheduler.new.add_teacher(student)).to be_falsy
    expect(Course_Scheduler.new.add_student(teacher)).to be_falsy
  end

  it 'returns falsy value if no teachers or students were given yet' do
    expect(Course_Scheduler.new.schedule_courses).to be_falsy
  end
end
