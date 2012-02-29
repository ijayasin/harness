#!/usr/bin/ruby

$:.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'erubis'
require 'test_harness/option_parser'
require 'test_harness/stats_writer'

module TestHarness
class Runner

  INPUTS  = Dir.glob("/opt/apirally/harness/inputs/*").freeze
  
  rally_dir = "/opt/apirally/api-rally/"
#CLIENTS = [File.join(rally_dir,"messagepack_node/client.sh")]
#CLIENTS = [File.join(rally_dir,"messagepack_node/client.sh"),
#	   File.join(rally_dir,"no_scrubs/lovesocket")]
#CLIENTS = [File.join(rally_dir,"no_scrubs/lovesocket")]  
CLIENTS = [File.join(rally_dir,"avro/src/ruby/cli.rb")]
# File.join(rally_dir, "rest_json_c/client.rb")]

 # SERVERS = [File.join(rally_dir, "no_scrubs/server.js")]

  RUNNERS = ['node']
  ITERATIONS = [10,100,1000,10000]

  def initialize
  end

  def serialize(params)
    t = Time.now.utc
    puts "CWD: #{Dir.getwd()}"
    puts "INPUT: #{params['input']}"
      system("./#{params['client']} --serialize --object #{params['object']} -n #{params['iterations']} -f #{params['input']} > #{File.basename(params['input'])}.serialized") 
    Time.now.utc - t
  end

  def deserialize(params)
    t = Time.now.utc
    system("./#{params['client']} --deserialize --object #{params['object']} -n #{params['iterations']} -f #{File.basename(params['input'])}.deserialized")
    Time.now.utc - t
  end

  def echo(params)
    t = Time.now.utc
    system("bash #{params['client']} --echo --object #{params['object']} --host localhost -n #{params['iterations']} -f #{params['input']} > #{File.basename(params['input'])}.echo")
    Time.now.utc - t
  end

  def run(args=nil)

    stats = Hash.new do |h,k|
      h[k] = Hash.new{|hh,kk| hh[kk] = {} }
    end

    CLIENTS.each do |client|
      params = {}
      Dir.chdir(File.dirname(client)) do
#      	system("node #{File.basename(SERVERS[0])} &")
        params['client'] = File.basename(client)
        INPUTS.each do |input|
          params['object'] = File.basename(input)
          params['input'] = input
          ITERATIONS.each do |iteration|
            params['iterations'] = iteration
            stats[File.basename(params['client'])]['serialize']["#{File.basename(params['input'])}-#{iteration}"] = serialize(params)
            stats[File.basename(params['client'])]['deserialize']["#{File.basename(params['input'])}-#{iteration}"] = deserialize(params)
#            stats[File.basename(params['client'])]['echo']["#{File.basename(params['input'])}-#{iteration}"] = echo(params)
          end
        end
      end
    end
    graph_results(stats)
  end

  def graph_results(results)
    input_cases = []
    INPUTS.each do |input|
      ITERATIONS.each do |iteration|
        input_cases << "#{File.basename(input)}-#{iteration}"
      end
    end
    template_file = "results.html.erb"
    template = Erubis::Eruby.load_file(template_file)
    File.open('results.html', 'w') do |f|
      result = template.result({
        :clients => CLIENTS.collect { |client| File.basename(client) },
        :tests => ['serialize','deserialize','echo'],
        :inputs => input_cases,
        :data => results # data is a nested hash: data[client][test][object]
      })
      f.write result
    end
  end

end
end


if __FILE__ == $0
  TestHarness::Runner.new.run(ARGV.clone)
end
