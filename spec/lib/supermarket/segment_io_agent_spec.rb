require 'isolated_spec_helper'
require 'supermarket/segment_io_agent'

describe Supermarket::SegmentIoAgent do
  it 'is enabled if the configuration has a SEGMENT_IO_WRITE_KEY' do
    config = { 'SEGMENT_IO_WRITE_KEY' => 'hi' }
    agent = Supermarket::SegmentIoAgent.new(config)

    expect(agent.enabled?).to eql(true)
  end

  it 'is not enabled if the configuration has a blank SEGMENT_IO_WRITE_KEY' do
    config = { 'SEGMENT_IO_WRITE_KEY' => '' }
    agent = Supermarket::SegmentIoAgent.new(config)

    expect(agent.enabled?).to eql(false)
  end

  it 'is not enabled if the configuration has no SEGMENT_IO_WRITE_KEY' do
    config = {}
    agent = Supermarket::SegmentIoAgent.new(config)

    expect(agent.enabled?).to eql(false)
  end

  it 'keeps track of the last event tracked' do
    config = {}
    agent = Supermarket::SegmentIoAgent.new(config)
    agent.track_server_event('tick', time: 1)

    expect(agent.last_event).to eql(name: 'tick', properties: { time: 1 })
  end
end
