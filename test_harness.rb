#!/usr/bin/ruby

class TestHarness

  TEST_CASES = {
    :serialize        => "%s --serialize -f serialize.json",
    :deserialize      => "%s --deserialize -f deserialize.json",
    :echo             => "%s --echo -f echo.json",
    :modify_and_echo  => "%s --modify_and_echo -f modify_and_echo.json",
  }

  INPUT_FILES = {
    :serialize => 'serialize.json',
    :deserialize => 'deserialize.json'
  }

  def initialize
    @stats = Hash.new do |h,k|
      h[k] = Hash.new{|hh,kk| hh[kk] = {} }
    end
  end

  def clients
    [
      './protobufs',
      './avro'
    ]
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

end


if __FILE__ == $0
  TestHarness.new.run
end
