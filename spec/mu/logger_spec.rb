require_relative '../spec_helper'
require 'mu'
require 'stringio'

describe Mu::Logger do
  let(:output) { StringIO.new }
  let(:data) { { a: 1, b: 2 } }
  let(:nested_data) { { a: 1, b: 2, c: { a: 10, b: 11 } } }
  let(:overly_nested_data) { { a: 1, n: { a: 2, n: { a: 3, n: { a: 4, n: { a: 5, n: { a: 6, n: { a: 7, n: { a: 8 } } } } } } } } }
  let(:hostname) { Socket.gethostname }
  subject(:logger) { Mu::Logger.new(::Logger.new(output)) }

  def next_tic
    @time += 1
  end

  before(:all) do
    @time = Time.parse('01/01/2013T00:00:00Z')
  end

  after do
    Mu.logger = nil
  end

  def expect_log(level, event, data = {})
    log_msg = Mu::Logging::JsonLogFormatter.format_log(level, @time, nil, data.merge(event: event))
    expect(log_msg).to eql(output.string)
  end

  def expect_colored_log(level, event, data = {})
    log_msg = Mu::Logging::ColoredLogFormatter.format_log(level, @time, nil, data.merge(event: event))
    expect(log_msg).to eql(output.string)
  end

  before do
    allow(Time).to receive(:now) { @time }
    ENV.delete('LOG_FORMAT')
  end

  it { should respond_to(:debug) }
  it { should respond_to(:info) }
  it { should respond_to(:warn) }
  it { should respond_to(:error) }
  it { should respond_to(:fatal) }

  it 'should take an existing Logger instance' do
    subject
  end

  it 'should take Logger arguments' do
    Mu::Logger.new(STDOUT)
  end

  it 'defaults to STDOUT' do
    expect(::Logger).to receive(:new).with(STDOUT).and_call_original
    Mu::Logger.new
  end

  describe 'default logger' do
    it 'should return a logger for STDOUT' do
      # expect once, call twice to test memoization
      Mu.logger = nil
      expect(Mu::Logger).to receive(:new).once.with(STDOUT).and_return(true)
      Mu.logger
      Mu.logger
    end
  end

  it 'allows "STDOUT" to be specified as the log location' do
    expect(::Logger).to receive(:new).with(STDOUT).and_call_original
    Mu::Logger.new('STDOUT')
  end

  it 'allows "STDERR" to be specified as the log location' do
    expect(::Logger).to receive(:new).with(STDERR).and_call_original
    Mu::Logger.new('STDERR')
  end

  it 'allows "logs/test.log" to be specified as the log location' do
    expect(::Logger).to receive(:new).with('logs/test.log').and_return(::Logger.new(STDOUT))
    Mu::Logger.new('logs/test.log')
  end

  it 'outputs JSON event format when given a data payload' do
    logger.info('event_name', data)
    expect_log :info, 'event_name', 'a' => 1, 'b' => 2
  end

  it 'outputs flattened JSON event format when given a data payload with nested hashes' do
    logger.info('event_name', nested_data)
    expect_log :info, 'event_name', 'a' => 1, 'b' => 2, 'c.a' => 10, 'c.b' => 11
  end

  it 'outputs limited flattened JSON event format when given a data payload with nested hashes' do
    logger.info('event_name', overly_nested_data)
    expect_log :info, 'event_name', 'a' => 1,
               'n.a' => 2,
               'n.n.a' => 3,
               'n.n.n.a' => 4,
               'n.n.n.n.a' => 5,
               'n.n.n.n.n.a' => 6,
               'n.n.n.n.n.n.a' => 7,
               'n.n.n.n.n.n.n.TRUNCATED' => 'data nested deeper than 7 levels has been truncated'
  end

  it 'outputs JSON event format with message when given a string' do
    logger.info('event_name', 'testing')
    expect_log :info, 'event_name', 'message' => 'testing'
  end

  context 'calculated duration' do
    it 'should calculate duration and send it to the formatter' do
      logger.info('timed_event', extra: 1) { next_tic }
      expect_log :info, 'timed_event', 'extra' => 1, 'duration' => 1000.0
    end

    it 'adds exception data to the event and re-raises the exception' do
      expect {
        logger.info('error_event', extra: 1) { raise StandardError, 'boom' }
      }.to raise_error(StandardError)

      expect_log :info, 'error_event',
                 'extra' => 1, 'exception' => %w(StandardError boom), 'duration' => 0.0
    end
  end

  describe 'default logger' do
    it 'should return a logger for STDOUT' do
      # expect once, call twice to test memoization
      Mu.logger = nil
      expect(Mu::Logger).to receive(:new).once.with(STDOUT).and_return(true)
      Mu.logger
      Mu.logger
    end
  end

  describe 'its logger' do
    it "sets the default log level to ENV['LOG_LEVEL']" do
      begin
        orig, ENV['LOG_LEVEL'] = ENV['LOG_LEVEL'], 'warn'
        expect(logger.level).to eql(Logger::WARN)
      ensure
        ENV['LOG_LEVEL'] = orig
      end
    end

    it 'should only log levels at or above its level' do
      logger.level = Logger::INFO
      logger.info 'event.info'
      logger.debug 'event.debug'
      expect_log :info, 'event.info'
    end
  end

  describe '#for_event' do
    it "should implicitly set event to 'default_event'" do
      logger.for_event('default_event').warn('my message')
      event = JSON.parse(output.string)
      expect(event['message']).to eq('my message')
      expect(event['event']).to eq('default_event')
    end
  end

  describe 'log formatting' do
    it 'should use colored logging with LOG_FORMAT=colored' do
      begin
        orig, ENV['LOG_FORMAT'] = ENV['LOG_FORMAT'], 'colored'
        logger.info('an_event', datum: 'value')
        expect_colored_log(:info, 'an_event', datum: 'value')
      ensure
        ENV['LOG_FORMAT'] = orig
      end
    end
  end
end
