# frozen_string_literal: true

class Graph
  attr_reader :graph, :source_key, :sink_key

  def initialize(edges = [])
    raise TypeError unless edges.respond_to?(:each)

    build_graph_from(edges)
  end

  def add_edge(edge)
    raise TypeError unless edge[:from] && edge[:to]

    try_to_add_edge(edge)
    rescue TypeError
      puts edge
      raise TypeError, 'Element is not an edge'
  end

  def bulk_add_edges(edges)
    edges.each { |edge| add_edge(edge) }
  end

  def add_solver(solver)
    solver.solver? && @solver = solver
    self
  rescue NoMethodError
    puts "#{solver} is not a solver"
    raise TypeError
  end

  def source_key=(source_key)
    return puts "#{source_key} not in graph." unless @graph[:from][source_key]
    @source_key = source_key
  end

  def sink_key=(sink_key)
    return puts "#{sink_key} not in graph." unless @graph[:from][sink_key]
    @sink_key = sink_key
  end

  def solve
    return puts 'No solver added' unless @solver
    @solver.solve(
      graph: @graph,
      source_key: @source_key,
      sink_key: @sink_key
    )
  end

  private
  def build_graph_from(edges)
    @graph = { from: {} }
    bulk_add_edges(edges)
  end

  def try_to_add_edge(edge)
    @graph[:from][edge[:from]] ||= { to: {} }
    @graph[:from][edge[:to]] ||= { to: {} }
    @graph[:from][edge[:from]][:to][edge[:to]] = edge[:data]
    self
  end
end
