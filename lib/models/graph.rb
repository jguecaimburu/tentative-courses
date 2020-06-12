# frozen_string_literal: true

class Graph
  attr_reader :graph

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

  private

  def build_graph_from(edges)
    @graph = { from: {} }
    bulk_add_edges(edges)
  end

  def try_to_add_edge(edge)
    @graph[:from][edge[:from]] ||= { to: {} }
    @graph[:from][edge[:to]] ||= { to: {} }
    @graph[:from][edge[:from]][:to][edge[:to]] = edge[:data]
    @graph
  end
end
