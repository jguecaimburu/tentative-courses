# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/graph'

RSpec.describe Graph do
  it 'is initialized with no argument' do
    expect { Graph.new }.not_to raise_error
  end

  it 'is initialized with empty iterable' do
    edges = []
    expect{ Graph.new(edges) }.not_to raise_error
  end

  it 'raises type error if given edges does not responds to each method' do
    edges = '1 2 3'
    expect{ Graph.new(edges) }.to raise_error(TypeError)
  end

  it 'raises type error if any item from iterable does not behave as edge' do
    edges = [1, 2, 3]
    expect{ Graph.new(edges) }.to raise_error(TypeError)
  end

  it 'creates a graph with edges as lists at nodes keys' do
    edges = [
      { from: 1, to: 2, data: '' },
      { from: 2, to: 3, data: '' },
      { from: 2, to: 4, data: '' },
      { from: 3, to: 4, data: '' }
    ]
    graph = Graph.new(edges)
    expect(graph.graph[:from][1][:to].size).to eq(1)
    expect(graph.graph[:from][2][:to].size).to eq(2)
    expect(graph.graph[:from][3][:to].size).to eq(1)
    expect(graph.graph[:from][4][:to].size).to eq(0)
  end

  it 'adds edge correctly' do
    edge = { from: 1, to: 2, data: '' }
    graph = Graph.new
    graph.add_edge(edge)
    expect(graph.graph[:from][1][:to].size).to eq(1)
  end

  it 'raises error if given object is not an edge' do
    edge = { foo: 1, bar: 2 }
    graph = Graph.new
    expect{ graph.add_edge(edge) }.to raise_error(TypeError)
  end

  it 'add bulk of edges' do
    graph = Graph.new
    edges = [
      { from: 1, to: 2, data: '' },
      { from: 2, to: 3, data: '' },
      { from: 2, to: 4, data: '' },
      { from: 3, to: 4, data: '' }
    ]
    graph.bulk_add_edges(edges)
    expect(graph.graph[:from][1][:to].size).to eq(1)
    expect(graph.graph[:from][2][:to].size).to eq(2)
    expect(graph.graph[:from][3][:to].size).to eq(1)
    expect(graph.graph[:from][4][:to].size).to eq(0)
  end
end
