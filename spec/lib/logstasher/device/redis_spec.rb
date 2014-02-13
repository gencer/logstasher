require 'spec_helper'

require 'logstasher/device/redis'

describe LogStasher::Device::Redis do

  let(:redis_mock) { double('Redis') }

  let(:default_options) {{
    key: 'logstash',
    data_type: 'list'
  }}

  it 'has default options' do
    device = LogStasher::Device::Redis.new
    device.options.should eq(default_options)
  end

  it 'creates a redis connection' do
    ::Redis.should_receive(:new).with({})
    LogStasher::Device::Redis.new()
  end

  it 'forwards unkown options to redis' do
    ::Redis.should_receive(:new).with(hash_including(unknown: 'option'))
    LogStasher::Device::Redis.new(unknown: 'option')
  end

  it 'has a configurable key' do
    device = LogStasher::Device::Redis.new(key: 'the_key')
    device.key.should eq 'the_key'
  end

  describe '#write' do
    it "rpushes logs onto a list" do
      device = LogStasher::Device::Redis.new(data_type: 'list')
      device.redis.should_receive(:rpush).with('logstash', 'the log')
      device.write('the log')
    end

    it "rpushes logs onto a custom key" do
      device = LogStasher::Device::Redis.new(data_type: 'list', key: 'custom')
      device.redis.should_receive(:rpush).with('custom', 'the log')
      device.write('the log')
    end

    it "publishes logs onto a channel" do
      device = LogStasher::Device::Redis.new(data_type: 'channel', key: 'custom')
      device.redis.should_receive(:publish).with('custom', 'the log')
      device.write('the log')
    end
  end

end
