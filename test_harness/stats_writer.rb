require 'yaml'


# Reading YAML
#   http://juixe.com/techknow/index.php/2009/10/08/jamming-with-ruby-yaml/
module TestHarness
  class StatsWriter

    STATS_DIR = File.expand_path('./stats').freeze

    def initialize(start_time, opts={})
      @start_time = start_time
      @opts = opts || {}
    end

    def save(stats_obj)
      File.open( filename, 'w' ) do |out|
        puts "\nWriting stats object to \"#{filename}\"\n"
        YAML.dump( stats_obj, out )
      end
    end

    protected

    def filename
      date = @start_time.strftime("%Y%m%d_%H%M%S")
      path = @opts[:path] || STATS_DIR
      File.join(path, "out-#{date}.yaml")
    end

  end
end
