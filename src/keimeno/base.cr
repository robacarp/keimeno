module Keimeno
  abstract class Base
    record Keystroke, type : Symbol, value : Symbol, data : Char

    SAVE_CURSOR = "\x1b7"
    RESTORE_CURSOR = "\x1b8"
    CLEAR_DOWN = "\x1b[J"
    CLEAR_SCREEN = "\x1b[2J"
    CLEAR_LINE = "\x1b[K"

    SHOW_CURSOR = "\x1b[?25h"
    HIDE_CURSOR = "\x1b[?25l"

    LOCATE_CURSOR = "\x1b[6n"
    MOVE_CURSOR = "\x1b["

    BUFFER_SIZE = 12

    getter read_buffer = Bytes.new BUFFER_SIZE
    getter read_string = ""
    property full_screen = false

    private property finished = false

    def run
      if full_screen

        with_alternate_buffer do
          print SAVE_CURSOR
          display_loop
        end

        clear_screen
      else
        display
        print SAVE_CURSOR
        input_display_loop
      end

      cleanup
      return_value
    end

    def repaint
      clear_screen
      before_display
      display
    end

    def display_loop
      loop do
        repaint
        wait_for_input

        break if finished?
      end
    end

    def input_display_loop
      loop do
        clear_line
        show_input
        wait_for_input
        break if finished?
      end
    end

    def display; end
    def before_display; end
    def cleanup; end
    def return_value; end
    def show_input; end

    def clear
      if full_screen?
        clear_screen
      else
        clear_line
      end
    end

    def clear_screen
      print RESTORE_CURSOR
      print CLEAR_DOWN
    end

    def clear_line
      print RESTORE_CURSOR
      print CLEAR_LINE
    end

    {% begin %}
      {%
       special_keys = [
         :ctrl_a, :ctrl_b, :ctrl_c, :ctrl_d,
         :ctrl_e, :ctrl_f, :ctrl_g, :ctrl_h,
         :ctrl_i, :ctrl_j, :ctrl_k, :ctrl_l,
         :ctrl_n, :ctrl_o, :ctrl_p, :ctrl_q,
         :ctrl_r, :ctrl_s, :ctrl_t, :ctrl_u,
         :ctrl_v, :ctrl_w, :ctrl_x, :ctrl_y,
         :ctrl_z,

         :alt_a, :alt_b, :alt_c, :alt_d,
         :alt_e, :alt_f, :alt_g, :alt_h,
         :alt_i, :alt_j, :alt_k, :alt_l,
         :alt_m, :alt_n, :alt_o, :alt_p,
         :alt_q, :alt_r, :alt_s, :alt_t,
         :alt_u, :alt_v, :alt_w, :alt_x,
         :alt_y, :alt_z,

         :alt_1, :alt_2, :alt_3,
         :alt_4, :alt_5, :alt_6,
         :alt_7, :alt_8, :alt_9,
         :alt_0, :alt_tilde,

         :alt_tab, :alt_space, :alt_enter,

         :alt_left_square_bracket, :alt_right_square_bracket,
         :alt_left_curly_bracket,  :alt_right_curly_bracket,

         :alt_period, :alt_greater_than,
         :alt_comma, :alt_less_than,
         :alt_double_quote, :alt_quote,

         :enter,
         :backspace,
         :delete,
         :up_arrow,
         :down_arrow,
         :left_arrow,
         :right_arrow,
         :escape
       ]
      %}

      def character_key(keystroke); end

      def function_key(keystroke)
        case keystroke.value
        {% for key_name in special_keys %}
        when {{ key_name }} then key_{{ key_name.id }}
        {% end %}
        else
          puts "unknown function key: #{keystroke}"
        end
      end

      {% for key_name in special_keys %}
        def key_{{ key_name.id }}; end
      {% end %}
    {% end %}

    def key_ctrl_c
      cleanup
      puts ""
      exit 1
    end

    def key_pressed(keystroke : Keystroke)
      case keystroke.type
      when :function
        function_key keystroke
      else
        character_key keystroke
      end
    end

    def wait_for_input
      STDIN.raw do
        @read_buffer = Bytes.new BUFFER_SIZE
        count = STDIN.read @read_buffer

        # puts "read #{count} bytes at once: #{@read_buffer} #{@read_buffer.map{|c| c.chr}.join("").lstrip('\e').rstrip('\u{0}')}"
        # puts
        # puts "read: #{@read_buffer.inspect}"
        # puts
        keystroke = nil
        return if count == 0

        @read_string = @read_buffer.map(&.chr).join("").rstrip('\u{0}')

        if count == 1
          keystroke = process_input_char
        else
          keystroke = decode_function_character
        end

        return unless keystroke
        key_pressed keystroke
      end
    end

    def process_input_char : Keystroke
      first_char = read_buffer.first.chr

      case first_char
      when .control?
        decode_control_character
      when .alphanumeric?
        Keystroke.new type: :alphanumeric, value: :letter, data: first_char
      when .whitespace?
        Keystroke.new type: :whitespace, value: :unknown, data: first_char
      else
        puts "unrecognized character: #{first_char} - #{read_buffer.first}"
        Keystroke.new type: :unknown, value: :unknown, data: first_char
      end
    end

    def decode_control_character : Keystroke
      key = case read_buffer.first
      when 1 then :ctrl_a
      when 2 then :ctrl_b
      when 3 then :ctrl_c
      when 4 then :ctrl_d
      when 5 then :ctrl_e
      when 6 then :ctrl_f
      when 7 then :ctrl_g
      when 8 then :ctrl_h
      when 9 then :ctrl_i
      when 10 then :ctrl_j
      when 11 then :ctrl_k
      when 12 then :ctrl_l
      when 13 then :enter
      when 14 then :ctrl_n
      when 15 then :ctrl_o
      when 16 then :ctrl_p
      when 17 then :ctrl_q
      when 18 then :ctrl_r
      when 19 then :ctrl_s
      when 20 then :ctrl_t
      when 21 then :ctrl_u
      when 22 then :ctrl_v
      when 23 then :ctrl_w
      when 24 then :ctrl_x
      when 25 then :ctrl_y
      when 26 then :ctrl_z
      when 27 then :escape
      when 127 then :backspace
      else
        puts "unknown control character: #{read_buffer.first}"
        :unknown_control
      end

      Keystroke.new type: :function, value: key, data: read_buffer.first.chr
    end

    def decode_function_character : Keystroke
      key = FunctionKeys.decode_bytes read_string
      Keystroke.new type: :function, value: key, data: '\0'
    end

    def show_cursor
      print SHOW_CURSOR
    end

    def hide_cursor
      print HIDE_CURSOR
    end

    def request_cursor_position
      print LOCATE_CURSOR

      row = 0
      col = 0

      STDIN.raw do
        @read_buffer = Bytes.new BUFFER_SIZE
        count = STDIN.read @read_buffer
        status = @read_buffer.map(&.chr).join("").lstrip('\e').rstrip('\u{0}')

        if data = /^\[(\d+);(\d+)R$/.match(status)
          row = data[1].to_i
          col = data[2].to_i
        end
      end

      { row, col }
    end

    def set_cursor_position(row = 1, col = 1)
      print MOVE_CURSOR
      print row
      print ';'
      print col
      print 'H'
    end

    def bump_cursor(row = 0, col = 0)
      current_row, current_col = request_cursor_position
      set_cursor_position current_row + row, current_col + col
    end

    def maintain_saved_cursor
      row, col = request_cursor_position
      yield
      set_cursor_position row, col
      print SAVE_CURSOR
    end

    def finished?
      finished
    end

    def finish!
      self.finished = true
    end

    def full_screen?
      full_screen
    end
  end
end
