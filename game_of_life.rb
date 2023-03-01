def game_of_life(generations, step=0)
    board = seed
    y = board.length()
    x = board[0].length()
    print_board board, 0, step
    reason = generations.times do |gen|
        new = evolve board, x, y
        print_board new, gen+1, step
        break :all_dead if desert? new
        break :static   if board == new
        board = new
    end
    if reason == :all_dead then puts "desert -> all dead"
    elsif reason == :static then puts "no movement"
    else puts "specified lifetime ended"
    end
    puts
end

def new_board(x, y)
    Array.new(y) {Array.new(x, 0)}
end

def read_input()
    file_input = "init.txt"
    if File.exists?(file_input)
        puts "I'm sowing..."
    else
        puts "missing #{file_input}"
        exit(0)
    end
    file = File.open(file_input)

    # check chars
    file.each_char { |char|
        if not(char =~ /[\.*\n ]/)
            puts "error in file #{file_input}"
            print "-#{char}-"
            exit(1)
        else
            print char
        end
    }

    file.seek(0)

    # check size
    file_data = file.readlines.map(&:chomp)
    rows_length = Array.new()
    file_data.each {|row|
        rows_length.push( row.split.join.split(//).join().length() )
    }
    if rows_length.select {|i| i != rows_length[0]}.length() > 0
        puts "error in file size"
        exit(1)
    end

    puts "\n\tand rest..."
    return file_data
end

def seed()
    file_data = read_input()
    board = Array.new()
    y = 0
    file_data.each {|row| 
        board[y] = Array.new()
        row.split.join.split(//).each {|val|
            board[y].push(val == '*' ? 1 : 0)
        }
        y += 1
    }
    return board
end

def evolve(board, x, y)
    new = new_board x, y
    y.times {|i| x.times {|j| new[i][j] = fate board, i, j, x, y}}
    new
end

def fate(board, i, j, x, y)
    i1 = [0, i-1].max; i2 = [i+1, y-1].min
    j1 = [0, j-1].max; j2 = [j+1, x-1].min
    sum = 0
    for ii in (i1..i2)
        for jj in (j1..j2)
            sum += board[ii][jj] if not (ii == i and jj == j)
        end
    end
    (sum == 3 or (sum == 2 and board[i][j] == 1)) ? 1 : 0
end

def desert?(board)
    n = board.length()
    n.times {|i| n.times {|j| return false if board[i][j] == 1}}
    true
end

def print_board(m, generation, step)
    if step == 1
        sleep 1
        system "clear"
    else
        puts
    end
    puts "generation #{generation}"
    m.each {|row| row.each {|val| print "#{val == 1 ? '#' : '.'} "}; puts}
end

if ARGV[0] =~ /\D/
    puts "Number of generation must be integer"
    exit(0)
end
if ARGV[1] and not(ARGV[1] =~ /[01]/)
    puts "Verbosity must be 0 or 1"
    exit(0)
end

game_of_life ARGV[0].to_i, ARGV[1].to_i
