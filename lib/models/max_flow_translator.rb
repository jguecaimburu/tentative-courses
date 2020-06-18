# frozen_string_literal: true

class MaxFlowTranslator
  class ValueError < StandardError; end

  HCLINK_PREFIX = 'HCLINK'
  HC_TRANSLATION = 'UNSOLVED'

  def initialize(origin_nodes:)
    raise TypeError unless origin_nodes.respond_to?(:each)
    raise ValueError if origin_nodes.empty?

    @origin_nodes = origin_nodes
    @translation = {}
  end

  def translate(max_flow_solution)
    max_flow_solution[:from].each do |id, adjacents|
      next unless @origin_nodes[id]

      add_id_to_translation(id, adjacents)
    end
    add_flow_to_translation(max_flow_solution)
    filter_empty_lists
  end

  private

  def add_id_to_translation(id, adjacents)
    adjacents[:to].each do |adjacent_id, adjacent_data|
      adjacent_id = HC_TRANSLATION if adjacent_id.start_with?(HCLINK_PREFIX)
      @translation[adjacent_id] ||= { list: [], flow: 0 }
      @translation[adjacent_id][:list] << id if adjacent_data[:flow].positive?
    end
  end

  def add_flow_to_translation(max_flow_solution)
    max_flow_solution[:from].each do |id, adjacents|
      id = HC_TRANSLATION if id.start_with?(HCLINK_PREFIX)
      next unless @translation[id]

      adjacents[:to].each do |_, adjacent_data|
        @translation[id][:flow] = adjacent_data[:flow]
      end
    end
  end

  def filter_empty_lists
    @translation.reject do |_, translation_data|
      translation_data[:list].empty?
    end
  end
end
