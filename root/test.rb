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
  config.relation(:game) do
    schema(infer: true) do
      associations do
        belongs_to :session, as: :session, relation: :session, foreign_key: :session_id
      end
    end
    auto_struct true
  end
  config.relation(:session) do
    schema(infer: true) do
      associations do
        belongs_to :player, as: :player0, relation: :player, foreign_key: :player_id0
        belongs_to :player, as: :player1, relation: :player, foreign_key: :player_id1
        has_many :game, as: :games, relation: :game
      end
    end
    auto_struct false # 無意味？
  end
end

module GnubgDatabase

  class SessionRepo < ::ROM::Repository[:session]
    #def query(conditions)
    #  session.where(conditions).to_a
    #end

    def matches
      session.where{ length > 0 }.combine(:player0, :player1, :games).to_a
    end

    def by_id(id)
      session.combine(:player0, :player1, :games).by_pk(id).one!
    end


    def output_score_transitions(destination: $stdout)
      matches.each do |match|

        games = match.games
        score_transition = games[1..-1].map do |game|   
          [game.score_0, game.score_1]
        end
      
        last_game = games.last
        # 最終結果【旧仕様】
        #if last_game
        #    if @winners[last_game[2]] == session[1]
        #        score_transition.push([last_game[3] + last_game[5], last_game[4]])
        #    elsif @winners[last_game[2]] == session[2]
        #        score_transition.push([last_game[3], last_game[4] + last_game[5]])
        #    end
        #end
      
        # 最終結果【新仕様】
        if last_game # 普通はnilにならない
          if last_game.result > 0
              score_transition.push([last_game.score_0 + last_game.result, last_game.score_1])
          elsif last_game.result < 0
              score_transition.push([last_game.score_0, last_game.score_1 - last_game.result])
          end
        end
      
      
        # 出力
        destination.puts match.player0.name
        destination.puts match.player1.name
        destination.puts " #{match.length} point match" # Initial space is essential.
        score_transition.each do |st|
          destination.puts st.join(' ')
        end
      
        destination.puts ''
      
      end
    end

  end

end

session_repo = GnubgDatabase::SessionRepo.new(rom)
session_repo.output_score_transitions

#match = session_repo.by_id(15)

#p session_repo.query(player_id0: 2)

