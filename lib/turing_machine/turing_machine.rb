require "yaml"
require "native_btree"

module TuringMachine
  RIGHT = 'r'.freeze
  LEFT = 'l'.freeze
  STOP = 's'.freeze
  DIRECT_REGEX = /^[rls]$/

  class << self
    def start(path)
      puts "Run!"

      config_path = File.realpath(path)
      data = YAML.load_file(config_path).transform_keys(&:to_sym)
      puts data

      tape = NativeBtree::Btree.new(NativeBtree::Btree::INT_COMPARATOR)

      # Сформируем алфавит
      alpha = {}
      data[:alpha].each_char do |char|
        alpha[char] = char
      end
      alpha[' '] = ' ' # Это тоже входит в алфавит

      # Наносим на ленту исходную строку
      idx = 0
      data[:tape].each_char do |char|
        unless alpha.key? char
          raise ArgumentError, "Unexpected symbol on tape - #{char}"
        end

        tape[idx] = char
        idx += 1
      end

      table = []
      stop_is_found = false
      data[:rules].each do |rule|
        from, head, sym, direct, to = rule
        table[from] = {} unless table[from]

        if (table[from].key? head)
          raise ArgumentError, "Rule for symbol [#{head}] in state [#{from}] already exists! - #{rule}"
        end

        unless alpha.key? head
          raise ArgumentError, "Unexpected head symbol in rule - #{head}"
        end

        unless alpha.key?(sym) || sym.nil?
          raise ArgumentError, "Unexpected replace symbol in rule - #{head}"
        end

        unless DIRECT_REGEX.match direct
          raise ArgumentError, "Unexpected direct symbol - #{direct}"
        end

        table[from][head] = {
          sym: sym,
          direct: direct,
          state: to
        }

        if !stop_is_found && direct == STOP
          stop_is_found = true
        end
      end

      unless stop_is_found
        raise ArgumentError, "Stop state is not found"
      end

      position = data[:start]
      state = 0
      # Тут всё готово чтобы запустить машину

      # Обрабатываем пока что-нить не случиться или не придём в конечный стэйт
      loop do
        sleep 0.1
        puts "\nSTATE: #{state}"
        print_tape(tape, position)

        # Чётам видит головка
        symbol = tape[position]
        symbol = ' ' if symbol.nil?

        # Чётам есть в таблице для текущего стэйта и символа
        state_rules = table[state]
        unless state_rules
          raise "Unprocessable state - #{state}"
        end

        action = state_rules[symbol]
        unless action
          raise "Action for symbol [#{symbol}] in state [#{state}] is not defined"
        end

        puts "ACTION: #{action} \n"

        unless action[:sym].nil?
          tape[position] = action[:sym]
        end

        case action[:direct]
        when LEFT
          position -= 1
        when RIGHT
          position += 1
        when STOP
          puts "STOP STATE REACHED. END PROGRAM."
          break
        else
          raise "Fatal error. Can't move head."
        end

        unless action[:state].nil?
          state = action[:state]
        end
      end

      puts "Done!"
    end

    def print_tape(tape, position)
      tape_string = ""
      head = ""

      max_key = nil
      tape.each do |char, key|
        tape_string << char
        head << "^" if key == position
        head << " " if key < position
        max_key = key
      end

      if position > max_key
        head = head[0, head.size - 1]

        while (position > max_key) do
          head << " "
          max_key += 1
        end

        head << "^"
      end

      puts tape_string
      puts head
    end
  end
end
