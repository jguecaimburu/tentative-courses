# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/student'
require_relative 'shared_context'

RSpec.shared_context 'student' do
  let(:graph_data_match) do
    {
      edges: [],
      link_nodes: ['ID-INTERMEDIATE-MON1500'],
      sink_key: 'SINK',
      source_key: 'SOURCE'
    }
  end

  let(:graph_data_two_matches) do
    {
      edges: [],
      link_nodes: %w[ID-INTERMEDIATE-MON1500
                     ID-INTERMEDIATE-TUE1600],
      sink_key: 'SINK',
      source_key: 'SOURCE'
    }
  end

  let(:graph_data_tolerance) do
    {
      edges: [],
      link_nodes: ['ID-INTERMEDIATE-FRI1500'],
      sink_key: 'SINK',
      source_key: 'SOURCE'
    }
  end

  let(:graph_data_no_match) do
    {
      edges: [],
      link_nodes: ['ID-BEGINNER-FRI1500'],
      sink_key: 'SINK',
      source_key: 'SOURCE'
    }
  end

  let(:default_course_size) { 6 }

  let(:tolerance) { 1 }
end

RSpec.describe Student do
  include_context 'student'
  include_context 'student instances'

  it 'affirm is a student when asked' do
    expect(@student.student?).to be true
  end

  it 'answer correctly about type' do
    expect(@student.type?('INDIVIDUAL')).to be true
    expect(@student.type?('GROUP')).to be false
  end

  it 'answer correctly about level' do
    expect(@student.level?('INTERMEDIATE')).to be true
    expect(@student.level?('ADVANCED')).to be false
  end

  it 'answer correctly about availability' do
    expect(@student.available?('MON1500')).to be true
    expect(@student.available?('TUE1500')).to be false
  end

  it 'raises ValueError if asked type is wrong' do
    expect { @student.type?('IND') }.to raise_error(Student::ValueError)
  end

  it 'raises ValueError if asked level is wrong' do
    expect { @student.level?('Inter') }.to raise_error(Student::ValueError)
  end

  it 'raises ValueError if asked schedule is wrong' do
    expect { @student.available?('Monday') }
      .to raise_error(Schedulable::ValueError)
  end

  it 'returns true if student is in scheduling order' do
    order = { student_type: 'INDIVIDUAL', level: 'INTERMEDIATE' }
    expect(@student.in_scheduling_order?(order)).to be true
  end

  it 'returns false if student is not in scheduling order' do
    order_group = { student_type: 'GROUP', level: 'INTERMEDIATE' }
    order_advanced = { student_type: 'INDIVIDUAL', level: 'ADVANCED' }
    expect(@student.in_scheduling_order?(order_group)).to be false
    expect(@student.in_scheduling_order?(order_advanced)).to be false
  end

  it 'returns true if scheduling order property is nil' do
    order_no_type = { level: 'INTERMEDIATE' }
    order_no_level = { student_type: 'INDIVIDUAL'}
    order_empty = {}
    expect(@student.in_scheduling_order?(order_no_level)).to be true
    expect(@student.in_scheduling_order?(order_no_type)).to be true
    expect(@student.in_scheduling_order?(order_empty)).to be true
  end

  it 'adds source and edge to student' do
    @student.build_graph_data(
      graph_data: graph_data_match,
      course_size: default_course_size
    )
    expect(graph_data_match[:edges].size).to eq(3)
  end

  it 'adds source and two edges to student' do
    @student.build_graph_data(
      graph_data: graph_data_two_matches,
      course_size: default_course_size
    )
    expect(graph_data_two_matches[:edges].size).to eq(4)
  end

  it 'does not add any edge if no match' do
    @student.build_graph_data(
      graph_data: graph_data_tolerance,
      course_size: default_course_size
    )
    expect(graph_data_tolerance[:edges].size).to eq(2)
  end

  it 'matches if no match but in tolerance' do
    @student.build_graph_data(
      graph_data: graph_data_tolerance,
      course_size: default_course_size,
      tolerance: tolerance
    )
    expect(graph_data_tolerance[:edges].size).to eq(3)
  end

  it 'does not match if level not available' do
    @student.build_graph_data(
      graph_data: graph_data_no_match,
      course_size: default_course_size,
      tolerance: tolerance
    )
    expect(graph_data_no_match[:edges].size).to eq(2)
  end

  it 'accumulates edges from different students' do
    @student.build_graph_data(
      graph_data: graph_data_match,
      course_size: default_course_size,
      tolerance: tolerance
    )
    @individual_student.build_graph_data(
      graph_data: graph_data_match,
      course_size: default_course_size,
      tolerance: tolerance
    )
    expect(graph_data_match[:edges].size).to eq(6)
  end

  it 'capacity of groupal for edge is 1' do
    @group_student.build_graph_data(
      graph_data: graph_data_match,
      course_size: default_course_size,
      tolerance: tolerance
    )
    expect(graph_data_match[:edges][0][:data][:capacity]).to eq(1)
  end

  it 'capacity of individual for edge is course_size' do
    @individual_student.build_graph_data(
      graph_data: graph_data_match,
      course_size: default_course_size,
      tolerance: tolerance
    )
    expect(graph_data_match[:edges][0][:data][:capacity])
      .to eq(default_course_size)
  end
end
