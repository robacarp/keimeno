require "./menu/*"
require "./text_input"

require "colorize"

module Keimeno
  class Menu < Base
    include TextInput

    getter heading
    getter options
    getter matches = [] of String
    getter choice : String?

    private property cursor_position = -1

    def initialize(@heading : String, @options : Array(String))
    end

    def formatted_options
      options.map_with_index do |option,index|
        color = :white
        background = :black

        if match?(option)
          color = :black

          if multiple_matches?
            background = :white
          else
            background = :green
          end
        end

        if cursor_position == index
          color = :black
          background = :green
        end

        " - #{option.colorize(color).on(background)}"
      end.join CRLF
    end

    def match?(o : String) : Bool
      return false if input_text.blank?
      Matcher.search(o).for(input_text)
    end

    def build_matches
      @matches = options.select { |o| match? o }
    end

    def multiple_matches?
      matches.size > 1
    end

    def before_display
      build_matches
    end

    def display
      puts heading
      puts formatted_options
      print "Choose: "

      print input_text
    end

    def return_value
      return options[cursor_position] if cursor_active?
      return matches.first if matches.size == 1
    end

    def character_key(keystroke) : Nil
      super
      self.cursor_position = -1
    end

    def key_enter
      if cursor_active?
        finish!
        @choice = options[cursor_position]
      else
        case matches.size
        when .>(1)
        when .==(1)
          finish!
          @choice = matches.first
        end
      end
    end

    def key_escape
      self.cursor_position = -1
      set_input_text ""
    end


    # methods for dealing with the cursor

    def cursor_active?
      cursor_position > -1
    end

    def decrement_cursor
      self.cursor_position -= 1
      if cursor_position < 0
        self.cursor_position = options.size - 1
      end
    end

    def increment_cursor
      self.cursor_position += 1
      if cursor_position >= options.size
        self.cursor_position = 0
      end
    end

    def key_up_arrow
      return if matches.size == 1
      return if options.size < 1

      decrement_cursor
      return if matches.empty?

      loop do
        break if match? options[cursor_position]
        decrement_cursor
      end
    end

    def key_down_arrow
      return if matches.size == 1
      return if options.size < 1

      increment_cursor
      return if matches.empty?

      loop do
        break if match? options[cursor_position]
        increment_cursor
      end
    end
  end
end
