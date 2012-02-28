require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

puts "OPTION_PARSER"

module TestHarness
  class OptionParser

    def self.default_options
      opts = OpenStruct.new
      opts.clients    = nil
      opts.test_cases = nil
      opts.host       = nil
      opts.stats_path = nil
      opts
    end

    def self.parse(args)
      options = default_options

      parser = ::OptionParser.new do |opts|

        opts.banner = "Usage: test_harness [--clients paths/to/clients] [--test-cases list,of,test,cases]"

        opts.on("--clients path-to-client1[,path-to-client2]", TestHarness::Runner::CLIENTS, TestHarness::Runner::CLIENTS.join(" ")) do |list|
          options.clients = list
        end

        test_cases_keys = TestHarness::Runner::TEST_CASES.keys

        opts.on("--test-cases ", test_cases_keys, "One or more Test Cases (%s)" % test_cases_keys.join(" ")) do |list|
          options.test_cases = list
        end

        opts.on("--host HOST_NAME", "Specify the host of the server.") do |host|
          options.host = host
        end

        opts.on("--stats_path path/to/stats/files", "Specify the path to where the stats files should be saved.") do |path|
          options.stats_path = path
        end

        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end

      end

      parser.parse!(args)

      options
    end

  end
end
