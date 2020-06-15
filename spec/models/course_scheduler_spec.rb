# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/course_scheduler'
require_relative '../../lib/models/student'
require_relative '../../lib/models/teacher'

RSpec.shared_context 'course scheduler' do
  before do
    @student = Student.new(
      id: 1,
      type: 'INDIVIDUAL',
      level: 'INTERMEDIATE',
      availability: %w[MON-1800 MON-1700 TUE-1600 FRI-1400]
    )
    @individual_student = Student.new(
      id: 2,
      type: 'INDIVIDUAL',
      level: 'INTERMEDIATE',
      availability: %w[MON-1500 MON-1600 TUE-1600 WED-1400]
    )
    @group_student = Student.new(
      id: 3,
      type: 'GROUP',
      level: 'INTERMEDIATE',
      availability: %w[MON-1500 MON-1600 TUE-1600 WED-1400]
    )
    @teacher = Teacher.new(
      id: 10,
      availability: %w[MON-1500 MON-1600 TUE-1600 WED-1400],
      levels: %w[INTERMEDIATE ADVANCED UPPER-INTERMEDIATE],
      max_courses: 3
    )
  end
end

RSpec.describe CourseScheduler do
  include_context 'course scheduler'

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

end
