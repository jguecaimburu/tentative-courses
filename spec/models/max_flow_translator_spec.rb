# frozen_string_literal: true

require 'rspec'
require_relative '../../lib/models/max_flow_translator'

RSpec.shared_context 'max flow translator' do
  before do
    @translator = MaxFlowTranslator.new(
      origin_nodes: {
        'NODE_1' => [],
        'NODE_2' => 1,
        'NODE_3' => '1',
        'NODE_10' => 1,
        'NODE_11' => {}
      }
    )
  end

  let(:solution) do
    {
      from: {
        'NODE_1' => {
          to: {
            'NODE_4' => { flow: 1 }
          }
        },
        'NODE_2' => {
          to: {
            'NODE_4' => { flow: 2 }
          }
        },
        'NODE_3' => {
          to: {
            'NODE_5' => { flow: 1 }
          }
        },
        'NODE_4' => {
          to: {
            'NODE_6' => { flow: 3 }
          }
        },
        'NODE_5' => {
          to: {
            'NODE_7' => { flow: 1 }
          }
        },
        'NODE_8' => {
          to: {
            'NODE_9' => { flow: 1 }
          }
        },
        'NODE_10' => {
          to: {
            'HCLINK_1' => { flow: 10 }
          }
        },
        'NODE_11' => {
          to: {
            'HCLINK_1' => { flow: 15 }
          }
        },
        'HCLINK_1' => {
          to: {
            'EXIT' => { flow: 25 }
          }
        }
      }
    }
  end

  let(:solution_empty) do
    {
      from: {}
    }
  end

  let(:solution_empty_origin) do
    {
      from: {
        'NODE_1' => {
          to: {
            'NODE_4' => { flow: 1 }
          }
        },
        'NODE_2' => {
          to: {}
        },
        'NODE_4' => {
          to: {
            'NODE_5' => { flow: 1 }
          }
        }
      }
    }
  end
end

RSpec.describe MaxFlowTranslator do
  include_context 'max flow translator'

  it 'returns correct translation on regular solution' do
    translation = @translator.translate(solution)
    expect(translation['NODE_4'][:list].size).to eq(2)
    expect(translation['NODE_4'][:flow]).to eq(3)
    expect(translation['NODE_5'][:list].size).to eq(1)
    expect(translation['NODE_5'][:flow]).to eq(1)
  end

  it 'does not include origin non destination nodes as keys' do
    translation = @translator.translate(solution)
    expect(translation['NODE_1']).to be_falsy
    expect(translation['NODE_8']).to be_falsy
  end

  it 'includes hclink as UNSOLVED' do
    translation = @translator.translate(solution)
    expect(translation['UNSOLVED'][:list].size).to eq(2)
    expect(translation['UNSOLVED'][:flow]).to eq(25)
  end

  it 'returns empty translation on empty solution' do
    expect(@translator.translate(solution_empty).empty?).to be true
  end

  it 'returns correct translation on empty origin node' do
    translation = @translator.translate(solution_empty_origin)
    expect(translation['NODE_4'][:list].size).to eq(1)
    expect(translation['NODE_4'][:flow]).to eq(1)
    expect(translation.size).to eq(1)
  end

  it 'raises errors on incorrect or empty origins' do
    expect { MaxFlowTranslator.new(origin_nodes: 1) }.to raise_error(TypeError)
    expect { MaxFlowTranslator.new(origin_nodes: []) }
      .to raise_error(MaxFlowTranslator::ValueError)
  end
end
