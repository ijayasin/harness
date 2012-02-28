#!/usr/bin/ruby

$:.unshift(File.dirname(__FILE__))
require 'test_harness/option_parser'

module TestHarness
class Runner

  TEST_CASES = {
    'serialize'       => "%s --serialize -f serialize.json",
    'deserialize'     => "%s --deserialize -f deserialize.json",
    'echo'            => "%s --echo -f echo.json",
    'modify_and_echo' => "%s --modify_and_echo -f modify_and_echo.json",
  }.freeze

  CLIENTS = %w(./avro ./messagepack ./protobufs ./rest_json ./thrift ./websockets).freeze

  def initialize
    @stats = Hash.new do |h,k|
      h[k] = Hash.new{|hh,kk| hh[kk] = {} }
    end
  end

  def clients
    clnts = (@options && @options.clients)
    clnts.reject{|v| v.nil? || v.empty?} if clnts
    clnts || CLIENTS
  end

  def cases
    if @options && @options.test_cases
      @options.test_cases.reject{|v| v.nil? || v.emtpy?}
    else
      TEST_CASES.keys
    end
  end

  def run(args=nil)
    @options = TestHarness::OptionParser.parse(args)

    clients.each do |client|
      test client
    end

    puts stats.inspect
  end

  def test(client)
    ((@options && @options.test_cases) || TEST_CASES.keys).each do |test_case|
      test_cmd = TEST_CASES[test_case]
      start = Time.now
      cmd = test_cmd % client
      ##cmd = 'ls -l'
      puts "\n\nRUNNING: #{cmd}"
      puts `#{cmd}`
      elapsed = Time.now - start
      stats[client][test_case]['cmd']     = cmd
      stats[client][test_case]['elapsed'] = elapsed
    end
  end

  def stats
    @stats
  end

end
end


if __FILE__ == $0
  TestHarness::Runner.new.run(ARGV.clone)
end
