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

  it 'keeps track of the last event tracked' do
    config = double('Supermarket::Config', segment_io_write_key: nil)
    agent = Supermarket::SegmentIoAgent.new(config)
    agent.track_server_event('tick', nil, time: 1)

    expect(agent.last_event).to eql(name: 'tick', user_id: 'anonymous', properties: { time: 1 })
  end

  it 'tracks what user triggered the event' do
    config = double('Supermarket::Config', segment_io_write_key: nil)
    agent = Supermarket::SegmentIoAgent.new(config)
    agent.track_server_event('tick', double('User', id: 123), time: 1)

    expect(agent.last_event[:user_id]).to eql(123)
  end
end
