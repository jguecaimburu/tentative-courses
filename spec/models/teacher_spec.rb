# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/teacher'

RSpec.describe Teacher do
  it 'affirm is a teacher when asked' do
    expect(Teacher.new.teacher?).to be true
  end
end
