# frozen_string_literal: true

class Min_Cost_Max_Flow_Solver
  class ValueError < StandardError; end

  def initialize
    @residual_graph = { from: {} }
    @solution_graph = { from: {} }
  end

  def solve(graph:, source_key:, sink_key:)
    validate_graph_extremes(
      graph: graph,
      source_key: source_key,
      sink_key: sink_key
    )
    build_zero_flow_residual_graph(graph)
    augment_residual_graph_while_viable(
      source_key: source_key,
      sink_key: sink_key
    )
    process_solution(graph)
  end

  def solver?
    true
  end

  private

  def validate_graph_extremes(graph:, source_key:, sink_key:)
    raise ValueError unless graph[:from][source_key] && graph[:from][sink_key]
  rescue ValueError
    puts 'Sink or source not present in graph'
    raise
  end

  def build_zero_flow_residual_graph(graph)
    graph[:from].each do |node, adjacents|
      adjacents[:to].each do |adjacent, edge_data|
        zero_flow_edge = build_zero_flow_edge_if_valid(
          node: node,
          adjacent: adjacent,
          edge_data: edge_data
        )
        add_both_ways_edges(zero_flow_edge)
      end
    end
  end

  def build_zero_flow_edge_if_valid(node:, adjacent:, edge_data:)
    validate_edge(edge_data)
    build_zero_flow_edge(
      node: node,
      adjacent: adjacent,
      edge_data: edge_data
    )
  end

  def validate_edge(edge_data)
    validate_edge_data_presence(edge_data)
    validate_capacity(edge_data)
    validate_cost(edge_data)
  end

  def validate_edge_data_presence(edge_data)
    raise TypeError unless edge_data[:capacity] && edge_data[:cost]
  rescue TypeError
    puts 'Invalid edge'
    puts edge_data
    raise
  end

  def validate_capacity(edge_data)
    raise ValueError unless edge_data[:capacity] < Float::INFINITY
    raise ValueError unless edge_data[:capacity] > 0
  rescue ValueError
    puts "Capacity can't be infinite nor zero"
    puts edge_data
    raise
  end

  def validate_cost(edge_data)
    raise ValueError unless edge_data[:cost] < Float::INFINITY
  rescue ValueError
    puts "Cost can't be infinite"
    puts edge_data
    raise
  end

  def build_zero_flow_edge(node:, adjacent:, edge_data:)
    new_edge_data = edge_data.clone
    new_edge_data[:flow] = 0
    new_edge = {
      node: node,
      adjacent: adjacent,
      edge_data: new_edge_data,
      opposite: false
    }
  end

  def add_both_ways_edges(edge)
    add_edge_to_residual_graph(edge)
    add_edge_to_residual_graph(reverse_edge(edge))
  end

  def reverse_edge(edge)
    opposite_edge = edge.clone
    opposite_edge[:node] = edge[:adjacent]
    opposite_edge[:adjacent] = edge[:node]
    opposite_edge[:opposite] = true
    opposite_edge
  end

  def add_edge_to_residual_graph(node:, adjacent:, edge_data:, opposite:)
    @residual_graph[:from][node] ||= { to: {} }
    @residual_graph[:from][node][:to][adjacent] = {
      residual_capacity: calculate_residual_edge_capacity(
        flow: edge_data[:flow],
        capacity: edge_data[:capacity],
        opposite: opposite
      ),
      cost: calculate_residual_edge_cost(
        cost: edge_data[:cost],
        opposite: opposite
      )
    }
  end

  def calculate_residual_edge_capacity(flow:, capacity:, opposite:)
    opposite ? flow : capacity - flow
  end

  def calculate_residual_edge_cost(cost:, opposite:)
    opposite ? -cost : cost
  end

  def augment_residual_graph_while_viable(source_key:, sink_key:)
    while augmenting_path = find_augmenting_path(
      source_key: source_key,
      sink_key: sink_key
    )
      augment_residual_graph_through(augmenting_path)
    end
  end

  def find_augmenting_path(source_key:, sink_key:)
    nodes = build_residual_nodes_cost_from(source_key)
    queue = []
    queue << source_key
    until queue.empty?
      node = queue.shift
      relax_and_queue(
        nodes: nodes,
        node: node,
        queue: queue
      )
    end
    recover_path_from(sink_key: sink_key, nodes: nodes)
  end

  def build_residual_nodes_cost_from(source_key)
    residual_nodes = @residual_graph[:from].inject({}) do |nodes, node_pair|
      nodes[node_pair[0]] = {
        previous: false,
        current_cost: Float::INFINITY
      }
      nodes
    end
    residual_nodes[source_key][:current_cost] = 0
    residual_nodes
  end

  def relax_and_queue(nodes:, node:, queue:)
    @residual_graph[:from][node][:to].each do |adjacent, edge_data|
      if edge_data[:residual_capacity] > 0
        potential_cost = nodes[node][:current_cost] + edge_data[:cost]
        if nodes[adjacent][:current_cost] > potential_cost
          nodes[adjacent][:current_cost] = potential_cost
          nodes[adjacent][:previous] = node
          queue << adjacent
        end
      end
    end
  end

  def recover_path_from(sink_key:, nodes:)
    return nil unless nodes[sink_key][:current_cost] < Float::INFINITY

    path = []
    augment_capacity = Float::INFINITY
    node = sink_key
    path.unshift(sink_key)
    while previous_node = nodes[node][:previous]
      edge_data = @residual_graph[:from][previous_node][:to][node]
      edge_capacity = edge_data[:residual_capacity]
      augment_capacity = edge_capacity < augment_capacity ?
                          edge_capacity :
                          augment_capacity
      node = previous_node
      path.unshift(node)
    end
    augmenting_path = { order: path, min_capacity: augment_capacity}
  end

  def augment_residual_graph_through(path)
    flow = path[:min_capacity]
    node = path[:order].shift
    until path[:order].empty?
      adj = path[:order].shift
      @residual_graph[:from][node][:to][adj][:residual_capacity] -= flow
      @residual_graph[:from][adj][:to][node][:residual_capacity] += flow
      node = adj
    end
  end

  def process_solution(graph)
    solution_found = false
    graph[:from].each do |node, adjacents|
      @solution_graph[:from][node] = { to: {} }
      adjacents[:to].each do |adj, edge_data|
        @solution_graph[:from][node][:to][adj] = {}
        edge_flow = @residual_graph[:from][adj][:to][node][:residual_capacity]
        solution_found = true if edge_flow > 0
        @solution_graph[:from][node][:to][adj][:flow] = edge_flow
      end
    end
    solution_found ? @solution_graph : false
  end
end
