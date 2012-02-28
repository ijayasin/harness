#!/usr/bin/ruby

$:.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'erubis'
require 'test_harness/option_parser'
require 'test_harness/stats_writer'

module TestHarness
class Runner

  INPUTS  = Dir.glob("/Users/martinbrown/git/harness/inputs/*").freeze
  CLIENTS = Dir.glob("/Users/martinbrown/git/api-rally/*/*\.sh").freeze
  ITERATIONS = [10,100,1000,10000,100000]

  def initialize
    CLIENTS.each do |client|
      puts client
    end
    @start_time = Time.now
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

  def serialize(params)
    t = Time.now.utc
    %x("./#{params['client']} --serialize --object #{params['object']} -n #{params['iterations']} -f #{params['input']}")
    Time.now.utc - t
  end

  def deserialize(params)
    t = Time.now.utc
    %x("#{params['client']} --deserialize --object #{params['object']} -n #{params['iterations']} -f #{params['input']}")
    Time.now.utc - t
  end


  def run(args=nil)

    stats = Hash.new do |h,k|
      h[k] = Hash.new{|hh,kk| hh[kk] = {} }
    end

    clients.each do |client|
      params = {}
      Dir.chdir(File.dirname(client)) do
        params['client'] = File.basename(client)
        INPUTS.each do |input|
          params['object'] = File.basename(input)
          params['input'] = input
          ITERATIONS.each do |iteration|
            params['iterations'] = iteration
            stats[File.basename(params['client'])]['serialize']["#{params['input']}-#{iteration}"] = serialize(params)
            stats[File.basename(params['client'])]['deserialize']["#{params['input']}-#{iteration}"] = deserialize(params)
          end
        end
      end
    end

    pp stats
    StatsWriter.new(@start_time, :path=>@options.stats_path).save(@stats)
  end

  def stats
    @stats
  end

  def graph_results(results)
    template_file = "results.html.erb"
    template = Erubis::Eruby.load_file(template_file)
    template.result({
      :clients => CLIENTS.collect { |client| File.basename(client) },
      :tests => TEST_CASES.keys,
      :objects => MODIFY_ECHO_PARAMS.collect {|p| p['type']},
      :data => data # data is a nested hash: data[client][test][object]
    })
  end

end
end


if __FILE__ == $0
  TestHarness::Runner.new.run(ARGV.clone)
end
