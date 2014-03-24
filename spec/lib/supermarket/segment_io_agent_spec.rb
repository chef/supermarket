require 'isolated_spec_helper'
require 'supermarket/segment_io_agent'

describe Supermarket::SegmentIoAgent do
  it 'is enabled if the configuration has a segment_io_write_key' do
    config = double('Supermarket::Config', segment_io_write_key: 'hi')
    agent = Supermarket::SegmentIoAgent.new(config)

    expect(agent.enabled?).to eql(true)
  end

  it 'is not enabled if the configuration has a blank segment_io_write_key' do
    config = double('Supermarket::Config', segment_io_write_key: '')
    agent = Supermarket::SegmentIoAgent.new(config)

    expect(agent.enabled?).to eql(false)
  end

  it 'is not enabled if the configuration has no segment_io_write_key' do
    config = double('Supermarket::Config', segment_io_write_key: nil)
    agent = Supermarket::SegmentIoAgent.new(config)

    expect(agent.enabled?).to eql(false)
  end
end
