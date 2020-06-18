# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/course_scheduler'
require_relative 'course_scheduler_context'

RSpec.describe CourseScheduler do
  include_context 'basic course scheduler'
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

  it 'creates courses' do
    course_scheduler = CourseScheduler.new
    course_scheduler.bulk_add_students(students)
    course_scheduler.bulk_add_teachers(teachers)
    course_scheduler.schedule_courses

    expect(students.all?(&:assigned?)).to be true
  end

  it 'rejects order if teacher gets full before' do
    course_scheduler = CourseScheduler.new
    course_scheduler.bulk_add_students(individual_students)
    course_scheduler.bulk_add_teachers(single_course_teacher)
    courses = course_scheduler.schedule_courses

    expect(courses.size).to eq(1)
    expect(individual_students.one?(&:assigned?)).to be true
  end

  it 'leaves out of course the student with worst priority' do
    course_scheduler = CourseScheduler.new
    course_scheduler.bulk_add_students(seven_students)
    course_scheduler.bulk_add_teachers(seven_teacher)
    courses = course_scheduler.schedule_courses
    unassigned = course_scheduler.unassigned_students

    expect(courses.size).to eq(1)
    expect(unassigned.size).to eq(1)
    expect(unassigned[0].id).to include('OUT')
  end

  it 'chooses teacher with better priority' do
    course_scheduler = CourseScheduler.new
    course_scheduler.bulk_add_students(options_student)
    course_scheduler.bulk_add_teachers(options_teachers)
    courses = course_scheduler.schedule_courses

    expect(courses.size).to eq(1)
    expect(courses[0].id).to include(@teacher_options_best.id)
    expect(@teacher_options_best.full_assigned?).to be true
    expect(@teacher_options_worst.available?(courses[0].schedule)).to be true
  end

  it 'only finds solution with tolerance' do
    zero_tolerance_scheduler = CourseScheduler.new
    zero_tolerance_scheduler.bulk_add_students(late_student)
    zero_tolerance_scheduler.bulk_add_teachers(late_teacher)
    courses = zero_tolerance_scheduler.schedule_courses

    expect(courses.empty?).to be true
    expect(@student_late.assigned?).to be false

    tolerance_scheduler = CourseScheduler.new
    tolerance_scheduler.bulk_add_students(late_student)
    tolerance_scheduler.bulk_add_teachers(late_teacher)
    courses = tolerance_scheduler.schedule_courses(
      scheduling_orders: late_tolerance_order
    )

    expect(courses.empty?).to be false
    expect(@student_late.assigned?).to be true
  end

  it 'handles 40 students and 10 teachers' do
    start = Time.now
    course_scheduler = CourseScheduler.new
    course_scheduler.bulk_add_students(forty_random_students)
    course_scheduler.bulk_add_teachers(ten_random_teachers)
    course_scheduler.schedule_courses
    unassigned = course_scheduler.unassigned_students
    execution_time = Time.now - start
    puts '40/10'
    print 'Unassigned: '
    puts unassigned.size
    print 'Execution time: '
    puts execution_time
  end

  it 'handles 200 students and 50 teachers' do
    start = Time.now
    course_scheduler = CourseScheduler.new
    course_scheduler.bulk_add_students(two_hundred_random_students)
    course_scheduler.bulk_add_teachers(fifty_random_teachers)
    courses = course_scheduler.schedule_courses
    unassigned = course_scheduler.unassigned_students
    execution_time = Time.now - start
    puts courses
    puts '200/50'
    print 'Unassigned: '
    puts unassigned.size
    print 'Execution time: '
    puts execution_time
  end
end
