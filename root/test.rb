require 'rom'

if ARGV.size < 1
    puts "Usage: test.rb db_filename"
    return
end

db_filename = ARGV[0]

rom = ROM.container(:sql, "sqlite://#{db_filename}") do |config|
  config.relation(:session) do
    schema(infer: true)
    auto_struct true
  end
end

module GnubgDatabase

  class Session < ::ROM::Repository[:session]
  end

end

session = GnubgDatabase::Session.new(rom)

