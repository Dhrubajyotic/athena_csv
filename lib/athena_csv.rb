require "athena_csv/version"
require "pg"
require "csv"

root_directory = File.expand_path("../", File.dirname(__FILE__))

Dir["#{root_directory}/lib/athena_csv/*.rb"].sort.each {|file| require file }

module AthenaCsv

  def self.config(args={})
    @config ||= Configuration.new(args)
  end
  
end
