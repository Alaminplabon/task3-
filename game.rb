require 'openssl'
require 'base64'

def hmac(key, message)
  OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, message)
end

def generate_key
  OpenSSL::Random.random_bytes(16).unpack('H*')[0]
end

def display_moves(moves)
  puts "Available moves:"
  moves.each_with_index { |move, index| puts "#{index + 1} - #{move}" }
  puts "0 - exit"
  puts "? - help"
end

def display_help_table(moves)
  puts "+--------+" + "--------+" * moves.length
  print "| NUMBER |"
  moves.each { |move| print " #{move.ljust(6)} |" }
  puts "\n+--------+" + "--------+" * moves.length

  moves.each_with_index do |move1, index1|
    print "| #{index1 + 1}     |"
    moves.each_with_index do |move2, index2|
      result = case (index1 - index2) % moves.length
               when 0 then "draw"
               when 1 then "Win"
               else "Lose"
               end
      print " #{result.ljust(6)} |"
    end
    puts "\n+--------+" + "--------+" * moves.length
  end

  puts "\ncount : #{moves.length}"
  puts "press enter to continue"
  $stdin.gets
end

def game(moves)
  if moves.length < 3
    puts "Error: You need to provide at least 3 moves."
    return
  elsif moves.length.even?
    puts "Error: Number of moves must be odd."
    return
  end

  key = generate_key
  computer_move = moves.sample
  hmac_digest = hmac(key, computer_move)

  puts "HMAC: #{hmac_digest}"

  loop do
    display_moves(moves)
    print "Enter your move: "
    choice = $stdin.gets.chomp.downcase
    break if choice == '0'
    if choice == '?'
      display_help_table(moves)
      next
    end

    unless choice.match?(/^\d+$/) && (1..moves.length).cover?(choice.to_i)
      puts "Invalid input. Please enter a valid move number."
      next
    end

    choice_index = choice.to_i - 1
    player_move = moves[choice_index]

    puts "Your move: #{player_move}"
    puts "Computer move: #{computer_move}"

    result = case (moves.index(player_move) - moves.index(computer_move)) % moves.length
             when 0 then "draw"
             when 1 then "you win!"
             else "Computer win!"
             end

    puts result
    puts "HMAC key: #{key}"

    break if choice == '0'
  end

  puts "Bye, bye!"
end

if ARGV.length < 3 || ARGV.any? { |move| move.match?(/^\d+$/) }
  puts "Moves should be non-numeric and at least 3."
else
  game(ARGV)
end
