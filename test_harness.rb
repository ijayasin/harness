#!/usr/bin/ruby

class TestHarness

  TEST_CASES = {
    :serialize        => "%s --serialize --object #{type} -f serialize.json",
    :deserialize      => "%s --deserialize --object #{type} -f deserialize.json",
    :echo             => "%s --echo --object #{type} --host #{host} -f echo.json",
    :modify_and_echo  => "%s --modify_and_echo --object #{type} --host #{host} --increment #{increment_key} --replace_key #{replace_key} --replace_value #{replace_value} -f modify_and_echo.json",
  }

  def initialize
    @stats = Hash.new do |h,k|
      h[k] = Hash.new{|hh,kk| hh[kk] = {} }
    end
  end

  def clients
    %w(./avro ./messagepack ./protobufs ./rest_json ./thrift ./websockets)
  end

  def run
    clients.each do |client|
      test client
    end

    puts stats.inspect
  end

  def test(client)
    TEST_CASES.each do |test_case, test_cmd|
      start = Time.now
      cmd = test_cmd % client
      ##cmd = 'ls -l'
      puts "\n\nRUNNING: #{cmd}"
      puts `#{cmd}`
      elapsed = Time.now - start
      stats[client][test_case]['elapsed'] = elapsed
    end
  end

  def stats
    @stats
  end

  def graph_results(results)

  end

end


if __FILE__ == $0
  TestHarness.new.run
end
