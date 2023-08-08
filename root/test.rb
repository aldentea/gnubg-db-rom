require 'rom'

if ARGV.size < 1
    puts "Usage: test.rb db_filename"
    return
end

db_filename = ARGV[0]

rom = ROM.container(:sql, "sqlite://#{db_filename}") do |config|
  config.relation(:player) do
    schema(infer: true)
    auto_struct true
  end
  config.relation(:session) do
    schema(infer: true) do
      associations do
        belongs_to :player, as: :player0, relation: :player, foreign_key: :player_id0
        belongs_to :player, as: :player1, relation: :player, foreign_key: :player_id1
      end
    end
    auto_struct false # 無意味？
  end
end

module GnubgDatabase

  class SessionRepo < ::ROM::Repository[:session]
    def query(conditions)
      session.where(conditions).to_a
    end

    def by_id(id)
      session.combine(:player0, :player1).by_pk(id).one!
    end

  end

end

session_repo = GnubgDatabase::SessionRepo.new(rom)

match = session_repo.by_id(4)
p match.player0
p match.player1

#p session_repo.query(player_id0: 2)

