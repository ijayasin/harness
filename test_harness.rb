#!/usr/bin/ruby

$:.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'erubis'
require 'test_harness/option_parser'
require 'test_harness/stats_writer'

module TestHarness
class Runner

  TEST_CASES = {
    'serialize'        => "%s --serialize --object $$TYPE$$ -f serialize.json",
    'deserialize'      => "%s --deserialize --object $$TYPE$$ -f deserialize.json",
    'echo'             => "%s --echo --object $$TYPE$$ --host $$HOST$$ -f echo.json",
    'modify_and_echo'  => "%s --modify_and_echo --object $$TYPE$$ --host $$HOST$$ --increment $$INCREMENT_KEY$$ --replace_key $$REPLACE_KEY$$ --replace_value $$REPLACE_VALUE$$ -f $$FILE$$"
  }.freeze

  CLIENTS = %w(./clients/avro ./clients/messagepack ./clients/protobufs ./clients/rest_json ./clients/thrift ./clients/websockets).freeze

  MODIFY_ECHO_PARAMS = [
    {'type' => 'bundle',         'increment_key' => 'inc_k', 'replace_key' => 'rep_k', 'replace_value' => 'rep_val', 'file' => 'bundle.json'         },
    {'type' => 'bundle',         'increment_key' => 'inc_k', 'replace_key' => 'rep_k', 'replace_value' => 'rep_val', 'file' => 'bundle_big.json'     },
    {'type' => 'creative',       'increment_key' => 'inc_k', 'replace_key' => 'rep_k', 'replace_value' => 'rep_val', 'file' => 'creative.json'       },
    {'type' => 'line_item',      'increment_key' => 'inc_k', 'replace_key' => 'rep_k', 'replace_value' => 'rep_val', 'file' => 'line_item.json'      },
    {'type' => 'lisp_stats',     'increment_key' => 'inc_k', 'replace_key' => 'rep_k', 'replace_value' => 'rep_val', 'file' => 'lisp_stats.json'     },
    {'type' => 'org',            'increment_key' => 'inc_k', 'replace_key' => 'rep_k', 'replace_value' => 'rep_val', 'file' => 'org.json'            },
    {'type' => 'site_placement', 'increment_key' => 'inc_k', 'replace_key' => 'rep_k', 'replace_value' => 'rep_val', 'file' => 'site_placement.json' }
  ]

  SPECIAL_TESTS = %w(modify_and_echo)

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

    pp stats
  end

  def test(client)
    ((@options && @options.test_cases) || TEST_CASES.keys).each do |test_case|
      test_cmd = TEST_CASES[test_case]
      if SPECIAL_TESTS.include?(test_case)
        special_tests(client, test_case, test_cmd)
      else
        start = Time.now
        cmd = test_cmd % client
        puts "\n\nRUNNING: #{cmd}"
        puts `#{cmd}`
        elapsed = Time.now - start
        ###stats[client][test_case]['cmd']     = cmd
        stats[client][test_case]['elapsed'] = elapsed
      end
    end
  end

  def special_tests(client, test_case, test_cmd)
    send(test_case.to_sym, client, test_case, test_cmd)
  end

  def modify_and_echo(client, test_case, test_cmd)
    puts "\n\nMODIFY_AND_ECHO   CLIENT=#{client}  TEST_CASE=#{test_case}  TEST_CMD=#{test_cmd}"
    MODIFY_ECHO_PARAMS.each do |params|
      start = Time.now
      test_case_type = "#{test_case}-#{params['type']}"
      cmd   = replace_placeholders(test_cmd, params)
      puts "\n\nRUNNING: #{cmd}"
      puts `#{cmd}`
      elapsed = Time.now - start
      ###stats[client][test_case_type]['cmd']     = cmd
      stats[client][test_case_type]['elapsed'] = elapsed
    end
  end

  def replace_placeholders(str_with_placeholders, params)
    str = str_with_placeholders.dup
    str = str.gsub('$$TYPE$$',          params['type']          )
    str = str.gsub('$$INCREMENT_KEY$$', params['increment_key'] )
    str = str.gsub('$$REPLACE_KEY$$',   params['replace_key']   )
    str = str.gsub('$$REPLACE_VALUE$$', params['replace_value'] )
    str = str.gsub('$$FILE$$',          File.expand_path(params['file'])  )
    str = str.gsub('$$HOST$$',          @options.host || 'HOST_IS_MISSING')
    str
  end

  def stats
    @stats
  end

  def graph_results(results)
    template_file = "results.html.erb"
    template = Erubis::Eruby.load_file(template_file)
    template.result({
      :clients => CLIENTS,
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
