# frozen_string_literal: true

require 'rspec'
require 'set'
require_relative '../../lib/models/teacher'

RSpec.shared_context 'teacher' do
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

  let(:graph_data) do
    {
      edges: [],
      link_nodes: [],
      sink_key: 'SINK',
      source_key: 'SOURCE'
    }
  end

  let(:default_course_size) { 6 }

  let(:student_requirements_match) do
    {
      levels: Set.new(['INTERMEDIATE']),
      availability: Set.new(%w[MON1500 MON1600 TUE1600 WED1400])
    }
  end

  let(:student_requirements_no_match) do
    {
      levels: Set.new(['INTERMEDIATE']),
      availability: Set.new(%w[MON1000 MON1700 TUE1300 WED1100])
    }
  end

  let(:student_requirements_empty) do
    {
      levels: Set.new(['INTERMEDIATE']),
      availability: Set.new([])
    }
  end
end

RSpec.describe Teacher do
  include_context 'teacher'

  it 'affirm is a teacher when asked' do
    expect(@teacher.teacher?).to be true
  end

  it 'create edge to source and one and edge for each match' do
    @teacher.build_graph_data(
      graph_data: graph_data,
      student_requirements: student_requirements_match,
      course_size: default_course_size
    )
    expect(graph_data[:edges].size).to eq(5)
    expect(graph_data[:link_nodes].size).to eq(4)
  end

  it 'accumulates edges and nodes for different teachers' do
    @teacher.build_graph_data(
      graph_data: graph_data,
      student_requirements: student_requirements_match,
      course_size: default_course_size
    )
    @other_teacher.build_graph_data(
      graph_data: graph_data,
      student_requirements: student_requirements_match,
      course_size: default_course_size
    )
    expect(graph_data[:edges].size).to eq(10)
    expect(graph_data[:link_nodes].size).to eq(8)
  end

  it 'does not create nodes or edges for courses if no schedule match' do
    @teacher.build_graph_data(
      graph_data: graph_data,
      student_requirements: student_requirements_no_match,
      course_size: default_course_size
    )
    expect(graph_data[:edges].size).to eq(1)
    expect(graph_data[:link_nodes].size).to eq(0)
  end

  it 'does not create nodes or edges for courses if no level match' do
    @beginner_teacher.build_graph_data(
      graph_data: graph_data,
      student_requirements: student_requirements_match,
      course_size: default_course_size
    )
    expect(graph_data[:edges].size).to eq(1)
    expect(graph_data[:link_nodes].size).to eq(0)
  end

  it 'does not create nodes or edges for courses on empty requirements' do
    @teacher.build_graph_data(
      graph_data: graph_data,
      student_requirements: student_requirements_empty,
      course_size: default_course_size
    )
    expect(graph_data[:edges].size).to eq(1)
    expect(graph_data[:link_nodes].size).to eq(0)
  end

  it 'sets edges capacities correctly' do
    @teacher.build_graph_data(
      graph_data: graph_data,
      student_requirements: student_requirements_match,
      course_size: default_course_size
    )
    expect(graph_data[:edges][0][:data][:capacity]).to eq(18)
    expect(graph_data[:edges][1][:data][:capacity]).to eq(default_course_size)
  end
end
