# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/student'

RSpec.describe Student do
  it 'affirm is a student when asked' do
    expect(Student.new.student?).to be true
  end
end
