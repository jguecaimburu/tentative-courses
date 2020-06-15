# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/graph'
require_relative '../../lib/models/min_cost_max_flow_solver'

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

  it 'returns truthy if solver added correctly' do
    solver = MinCostMaxFlowSolver.new
    expect(Graph.new.add_solver(solver)).to be_truthy
  end

  it 'raise TypeError if try to add wrong object to solver' do
    expect{ Graph.new.add_solver('solver') }.to raise_error(TypeError)
  end

  it 'sets source if key is present in graph' do
    graph = Graph.new.add_edge({ from: 1, to: 2, data: '' })
    graph.source_key = 1
    expect(graph.source_key).to eq(1)
  end

  it 'does not set source if key is not present in graph' do
    graph = Graph.new.add_edge({ from: 1, to: 2, data: '' })
    graph.source_key = 3
    expect(graph.source_key).to be_falsy
  end

  it 'sets sink if key is present in graph' do
    graph = Graph.new.add_edge({ from: 1, to: 2, data: '' })
    graph.sink_key = 2
    expect(graph.sink_key).to eq(2)
  end

  it 'does not set sink if key is not present in graph' do
    graph = Graph.new.add_edge({ from: 1, to: 2, data: '' })
    graph.sink_key = 3
    expect(graph.sink_key).to be_falsy
  end

  it 'returns falsy if try to solve but no solver added' do
    expect(Graph.new.solve).to be_falsy
  end
end
