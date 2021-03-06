require 'faraday'
require 'faraday-manual-cache'
require 'active_support'

class MockStore
  def fetch(*args) end
  def write(*args) end
end

RSpec.describe Faraday::ManualCache do
  let(:stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get('/') { |_| [200, {}, ''] }
      stub.head('/') { |_| [200, {}, ''] }
      stub.post('/') { |_| [200, {}, ''] }
      stub.put('/') { |_| [200, {}, ''] }
    end
  end
  let(:store) { ActiveSupport::Cache::MemoryStore.new }
  let(:configuration_double) { double(:configuration_double, memory_store: store) }

  before do
    allow(FaradayManualCache).to receive(:configuration).and_return(configuration_double)
  end

  context 'basic configuration' do
    subject do
      Faraday.new(url: 'http://www.example.com') do |faraday|
        faraday.use :manual_cache
        faraday.adapter :test, stubs
      end
    end

    it 'should cache on GET' do
      expect(store).to receive(:fetch)
      expect(store).to receive(:write)
      subject.get('/')
    end

    it 'should cache on HEAD' do
      expect(store).to receive(:fetch)
      expect(store).to receive(:write)
      subject.head('/')
    end

    it 'should not cache on POST' do
      expect(store).not_to receive(:fetch)
      expect(store).not_to receive(:write)
      subject.post('/')
    end

    it 'should not cache on PUT' do
      expect(store).not_to receive(:fetch)
      expect(store).not_to receive(:write)
      subject.put('/')
    end
  end

  context 'conditional configuration' do
    subject do
      Faraday.new(url: 'http://www.example.com') do |faraday|
        faraday.use :manual_cache, conditions: ->(_) { true }
        faraday.adapter :test, stubs
      end
    end

    it 'should cache on GET' do
      expect(store).to receive(:fetch)
      expect(store).to receive(:write)
      subject.get('/')
    end

    it 'should cache on HEAD' do
      expect(store).to receive(:fetch)
      expect(store).to receive(:write)
      subject.head('/')
    end

    it 'should cache on POST' do
      expect(store).to receive(:fetch)
      expect(store).to receive(:write)
      subject.post('/')
    end

    it 'should cache on PUT' do
      expect(store).to receive(:fetch)
      expect(store).to receive(:write)
      subject.put('/')
    end
  end
end
