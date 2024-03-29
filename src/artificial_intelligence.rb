# frozen_string_literal: true

class AI
  def self.neural_network(counter, place_4, board, fork_danger_1, fork_danger_2, fork_danger_3, array_of_games)
    if [0, 1].include?(counter)
      first_move(place_4)
    else
      run(board, fork_danger_1, fork_danger_2, fork_danger_3, array_of_games)
    end
  end

  def self.first_move(place_4)
    progress
    if !place_4
      puts "\nAI MOVE: 5"
      5
    else
      puts "\nAI MOVE: 1"
      1
    end
  end

  def self.run(board, fork_danger_1, fork_danger_2, fork_danger_3, array_of_games)
    data = nn_data(board, fork_danger_1, fork_danger_2, fork_danger_3, array_of_games)
    fann_results_array = []
    begin
      train = RubyFann::TrainData.new(inputs: data[0], desired_outputs: data[1])
      model = RubyFann::Standard.new(
        num_inputs: 1,
        hidden_neurons: [4],
        num_outputs: 1
      )
      model.train_on_data(train, 5000, 500, 0.01)
      data[0].flatten.each do |i|
        fann_results_array << model.run([i])
      end
    rescue StandardError
      []
      # Starting.beginning_of_game
      recreate_games_log
    end
    result = data[0][fann_results_array.index(fann_results_array.max)]
    print_info_1(data[0], fann_results_array, result[0])
    result[0]
  end

  def self.recreate_games_log
    print_info_2
    File.delete('ss.csv')
    require_relative './training'
    exit
  end

  def self.nn_data(board, fork_danger_1, fork_danger_2, fork_danger_3, array_of_games)
    current_position = board.to_s
    x_data = []
    y_data = []
    arrays = nn_arrays(board, fork_danger_1, fork_danger_2, fork_danger_3, array_of_games)
    print_info(arrays[0], arrays[1], arrays[2])
    array_of_games.each do |row|
      row.each do |e|
        next unless e == current_position

        next if arrays[0].include?(row[0])

        unless arrays[1].include?(row[0]) && !arrays[2].include?(row[0])
          case row[6].to_i - row[3].to_i
          when 1
            x_data.push([row[0].to_i])
            y_data.push([1])
          when 3
            if arrays[2].include?(row[0])
              x_data.push([row[0].to_i])
              y_data.push([0.9])
            elsif arrays[1].include?(row[0])
              x_data.push([row[0].to_i])
              y_data.push([0.3])
            end
          else
            x_data.push([row[0].to_i])
            y_data.push([row[2].to_f])
          end
        end
        next unless x_data.empty?

        unless arrays[0].include?(row[0])
          x_data.push([row[0].to_i])
          y_data.push([0.3])
        end
      end
    end
    [x_data, y_data]
  end

  def self.nn_arrays(board, fork_danger_1, fork_danger_2, fork_danger_3, array_of_games)
    unacceptable_moves_array = []
    array_of_moves_to_fork = []
    attack_moves_array = []
    current_position = board.to_s
    # Create a list of unacceptable moves, a list of moves leading to fork, a list of attacking moves:
    array_of_games.each do |row|
      row.each do |e|
        next unless e == current_position

        if row[6].to_i - row[3].to_i == 2 && row[2].to_f != 0.2
          unacceptable_moves_array << row[0]
        # Find moves that inevitably lead to a fork:
        elsif fork_danger_1 && row[3].to_i == (3 if @player1 == 'Human' || 2) && row[0].to_i.odd?
          unacceptable_moves_array << row[0]
        elsif (fork_danger_2 || fork_danger_3) && row[3].to_i == (3 if @player1 == 'Human' || 2) && row[0].to_i.even?
          unacceptable_moves_array << row[0]
        end
        next if row[5].nil?

        # Find moves that may lead to a fork:
        array_of_moves_to_fork << row[0] if row[3].to_i == row[5].to_i
        # Find attacking moves:
        attack_moves_array << row[0] if row[3].to_i == row[5].to_i && row[6].to_i < 7
      end
    end
    [unacceptable_moves_array, array_of_moves_to_fork, attack_moves_array]
  end

  def self.print_info(a, b, c)
    [[a, 'Unacceptable moves: '],
     [b, 'List of moves leading to fork: '],
     [c, 'Attack moves: ']].each do |i|
      print "#{i[1]}#{i[0].uniq}\n" if i[0].any?
    end
    print "\n"
  end

  def self.print_info_1(a, b, c)
    print "\n x_data=#{a}\n"
    print "\n FANN results: #{b}\n"
    puts ''
    chart(a, b)
    puts ''
    puts "\n AI MOVE: #{c}"
  end

  def self.print_info_2
    puts 'Sorry. TimeOut. AI will rebuild the game log now. Please wait...'
  end

  def self.progress
    0.step(40, 5) do |i|
      printf("\rAI works. Please wait... [%-8s]", '#' * (i / 5))
      sleep(0.1)
    end
    puts
  end

  def self.chart(a, b)
    tmp = []
    colors = %i[cyan red green yellow white magenta]
    data = [
      a.zip(b).uniq.each_with_index do |i, index|
        tmp << { name: i[0].join.to_i, value: i[1].join.to_f, color: colors[index], fill: i[0].join.to_s }
      end
    ]
    pie_chart = TTY::Pie.new(data: tmp, radius: 6, legend: { format: '%<label>s %<percent>.2f%%' })
    print pie_chart
  end
end
