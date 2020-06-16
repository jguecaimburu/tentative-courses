RSpec.shared_context 'student instances' do
  before do
    @student = Student.new(
      id: 1,
      type: 'INDIVIDUAL',
      level: 'INTERMEDIATE',
      availability: %w[MON1500 MON1700 TUE1600 FRI1400]
    )
    @individual_student = Student.new(
      id: 2,
      type: 'INDIVIDUAL',
      level: 'INTERMEDIATE',
      availability: %w[MON1500 MON1600 TUE1600 WED1400]
    )
    @group_student = Student.new(
      id: 3,
      type: 'GROUP',
      level: 'INTERMEDIATE',
      availability: %w[MON1500 MON1600 TUE1600 WED1400]
    )
    @other_group_student = Student.new(
      id: 4,
      type: 'GROUP',
      level: 'INTERMEDIATE',
      availability: %w[MON1500 MON1600 TUE1600 WED1400]
    )
    @third_group_student = Student.new(
      id: 5,
      type: 'GROUP',
      level: 'INTERMEDIATE',
      availability: %w[MON1500 MON1600 TUE1600 WED1400]
    )
    @beginner_group_student = Student.new(
      id: 6,
      type: 'GROUP',
      level: 'BEGINNER',
      availability: %w[MON1500 MON1600 TUE1600 WED1400]
    )
  end
end

RSpec.shared_context 'teacher instances' do
  before do
    @teacher = Teacher.new(
      id: 10,
      availability: %w[MON1500 MON1600 TUE1600 WED1400],
      levels: %w[INTERMEDIATE ADVANCED UPPER_INTERMEDIATE],
      max_courses: 3
    )
    @other_teacher = Teacher.new(
      id: 11,
      availability: %w[MON1500 MON1600 TUE1600 WED1400],
      levels: %w[INTERMEDIATE ADVANCED UPPER_INTERMEDIATE],
      max_courses: 3
    )
    @beginner_teacher = Teacher.new(
      id: 12,
      availability: %w[MON1500 MON1600 TUE1600 WED1400],
      levels: ['BEGINNER'],
      max_courses: 3
    )
  end
end
