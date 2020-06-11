# frozen_string_literal: true

class Graph
  attr_reader :graph

  def initialize(edges = [])
    raise TypeError unless edges.respond_to?(:each)

    @graph = build_graph_from(edges)
  end

  def add_edge(edge, graph = @graph)
    raise TypeError unless edge[:from] && edge[:to]

    try_to_add_edge(edge, graph)
    rescue TypeError
      puts edge
      raise TypeError, 'Element is not an edge'
  end

  private

  def build_graph_from(edges)
    edges.inject({}) do |graph, edge|
      add_edge(edge, graph)
    end
  end

  def try_to_add_edge(edge, graph)
    graph[edge[:from]] ||= []
    graph[edge[:to]] ||= []
    graph[edge[:from]] << edge
    graph
  end
end
