require 'yaml'


# Reading YAML
#   http://juixe.com/techknow/index.php/2009/10/08/jamming-with-ruby-yaml/
module TestHarness
  class StatsWriter

    def initialize(start_time, path)
      
    end

    def save(obj)
      File.open( 'animals.yaml', 'w' ) do |out|
        YAML.dump( ['badger', 'elephant', 'tiger'], out )
      end
    end

    protected

    def filename
      File.join(path, "#{}")
    end

  end
end
