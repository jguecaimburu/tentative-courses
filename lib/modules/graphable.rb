# frozen_string_literal: true

module Graphable
  def id
    raise NoMethodError, "#{self} should implement id"
  end

  private

  def add_own_edge_from_source(graph_data:, capacity:, cost:)
    add_edge(
      graph_data: graph_data,
      from: graph_data[:source_key],
      to: id.to_s,
      capacity: capacity,
      cost: cost
    )
  end

  def add_own_edge_to_sink(graph_data:, capacity:, cost:)
    add_edge(
      graph_data: graph_data,
      from: id.to_s,
      to: graph_data[:sink_key],
      capacity: capacity,
      cost: cost
    )
  end

  def add_edge(graph_data:, from:, to:, capacity:, cost:)
    edge = {
      from: from,
      to: to,
      data: {
        capacity: capacity,
        cost: cost
      }
    }
    graph_data[:edges] << edge
  end

  def add_edges_to_link_nodes(graph_data:, capacity:, cost:)
    graph_data[:link_nodes].each do |node|
      next unless match_node?(node)

      add_edge(
        graph_data: graph_data,
        from: id.to_s,
        to: node,
        capacity: capacity,
        cost: cost
      )
    end
  end

  def add_link_node_with_edge_from_it(graph_data:, node:, capacity:, cost:)
    graph_data[:link_nodes] << node
    add_edge(
      graph_data: graph_data,
      from: node,
      to: id.to_s,
      capacity: capacity,
      cost: cost
    )
  end

  def match_node?(_)
    raise NoMethodError, "#{self} should implement match_node"
  end
end
