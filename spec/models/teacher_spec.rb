# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/teacher'

RSpec.shared_context 'teacher' do
  before do
    @teacher = Teacher.new(
      id: 10,
      availability: %w[MON-1500 MON-1600 TUE-1600 WED-1400],
      levels: %w[INTERMEDIATE ADVANCED UPPER-INTERMEDIATE],
      max_courses: 3
    )
  end
end

RSpec.describe Teacher do
  include_context 'teacher'

  it 'affirm is a teacher when asked' do
    expect(@teacher.teacher?).to be true
  end
end
