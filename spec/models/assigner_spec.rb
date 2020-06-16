# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/assigner'
require_relative 'shared_context'

RSpec.shared_context 'assigner' do

end

RSpec.describe Assigner do
  include_context 'student instances'
  include_context 'teacher instances'
  include_context 'assigner'

  it 'jolis' do

  end
end
