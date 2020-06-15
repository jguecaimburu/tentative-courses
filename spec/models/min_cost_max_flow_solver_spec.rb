# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/min_cost_max_flow_solver'

describe MinCostMaxFlowSolver do
  it 'affirms is a solver when asked' do
    expect(MinCostMaxFlowSolver.new.solver?).to be true
  end

  it 'solves max flow with min cost' do
    graph = {
      from: {
        1 => {
          to: {
            2 => { capacity: 1, cost: 1 },
          }
        },
        2 => {
          to: {
            3 => { capacity: 1, cost: 1 },
            4 => { capacity: 1, cost: 2 },
          }
        },
        3 => {
          to: {
            5 => { capacity: 1, cost: 1 }
          }
        },
        4 => {
          to: {
            5 => { capacity: 1, cost: 1 }
          }
        },
        5 => { to: {} }
      }
    }
    source_key = 1
    sink_key = 5
    solution = MinCostMaxFlowSolver.new.solve(
      graph: graph,
      source_key: source_key,
      sink_key: sink_key
    )
    expect(solution[:from][3][:to][5][:flow]).to eq(1)
    expect(solution[:from][4][:to][5][:flow]).to eq(0)
  end

  it 'gives priority to max flow over min cost' do
    graph = {
      from: {
        1 => {
          to: {
            2 => { capacity: 2, cost: 1 },
          }
        },
        2 => {
          to: {
            3 => { capacity: 2, cost: 1 },
            4 => { capacity: 2, cost: 2 },
          }
        },
        3 => {
          to: {
            5 => { capacity: 1, cost: 1 }
          }
        },
        4 => {
          to: {
            5 => { capacity: 2, cost: 2 }
          }
        },
        5 => { to: {} }
      }
    }
    source_key = 1
    sink_key = 5
    solution = MinCostMaxFlowSolver.new.solve(
      graph: graph,
      source_key: source_key,
      sink_key: sink_key
    )
    expect(solution[:from][3][:to][5][:flow]).to eq(1)
    expect(solution[:from][4][:to][5][:flow]).to eq(1)
  end

  it 'raises error on wrong sink' do
    graph = {
      from: {
        1 => {
          to: {
            2 => { capacity: 1, cost: 1 },
          }
        },
        2 => {
          to: {}
        }
      }
    }
    sok = 1
    sik = 3
    solver = MinCostMaxFlowSolver.new
    expect{ solver.solve(graph: graph, source_key: sok, sink_key: sik) }
      .to raise_error(MinCostMaxFlowSolver::ValueError)
  end

  it 'raises error on wrong source' do
    graph = {
      from: {
        1 => {
          to: {
            2 => { capacity: 1, cost: 1 },
          }
        },
        2 => {
          to: {}
        }
      }
    }
    sok = 0
    sik = 2
    solver = MinCostMaxFlowSolver.new
    expect{ solver.solve(graph: graph, source_key: sok, sink_key: sik) }
      .to raise_error(MinCostMaxFlowSolver::ValueError)
  end

  it 'raises error on wrong edge structure' do
    graph = {
      from: {
        1 => {
          to: {
            2 => { cap: 1, cst: 1 },
          }
        },
        2 => {
          to: {}
        }
      }
    }
    sok = 1
    sik = 2
    solver = MinCostMaxFlowSolver.new
    expect{ solver.solve(graph: graph, source_key: sok, sink_key: sik) }
      .to raise_error(TypeError)
  end

  it 'raises error on wrong capacity' do
    graph = {
      from: {
        1 => {
          to: {
            2 => { capacity: 0, cost: 1 },
          }
        },
        2 => {
          to: {}
        }
      }
    }
    sok = 1
    sik = 2
    solver = MinCostMaxFlowSolver.new
    expect{ solver.solve(graph: graph, source_key: sok, sink_key: sik) }
      .to raise_error(MinCostMaxFlowSolver::ValueError)
  end

  it 'raises error on wrong cost' do
    graph = {
      from: {
        1 => {
          to: {
            2 => { capacity: 1, cost: Float::INFINITY },
          }
        },
        2 => {
          to: {}
        }
      }
    }
    sok = 1
    sik = 2
    solver = MinCostMaxFlowSolver.new
    expect{ solver.solve(graph: graph, source_key: sok, sink_key: sik) }
      .to raise_error(MinCostMaxFlowSolver::ValueError)
  end

  it 'returns false if no solution' do
    graph = {
      from: {
        1 => {
          to: {
            2 => { capacity: 1, cost: 1 },
          }
        },
        2 => {
          to: {}
        },
        3 => {
          to: {
            4 => { capacity: 1, cost: 1 },
          }
        },
        4 => {
          to: {}
        }
      }
    }
    sok = 1
    sik = 4
    solver = MinCostMaxFlowSolver.new
    expect(solver.solve(graph: graph, source_key: sok, sink_key: sik))
      .to be false
  end
end
