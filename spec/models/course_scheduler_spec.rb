# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/course_scheduler'
require_relative 'shared_context'

RSpec.shared_context 'course scheduler' do

end

RSpec.describe CourseScheduler do
  include_context 'course scheduler'
  include_context 'student instances'
  include_context 'teacher instances'
\
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

  # it 'runs' do
  #   course_scheduler = CourseScheduler.new
  #   course_scheduler.bulk_add_students(
  #     [@group_student, @other_group_student]
  #   )
  #   course_scheduler.bulk_add_teachers([@teacher])
  #   puts 'SCHEDULING TEST'
  #   puts course_scheduler.schedule_courses
  #   puts 'SCHEDULING TEST END'
  # end
end
