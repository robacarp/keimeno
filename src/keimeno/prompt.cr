module Keimeno
  class Prompt < Base
    include Keimeno::TextInput

    getter question, character_filter

    def initialize(@question : String, @character_filter = /[A-Za-z0-9._!?@#$%^&*()-]/)
    end

    def display
      print "#{question} #{input_text}"
    end

    def key_enter
      finish!
    end

    def key_escape
      set_input_text ""
      finish!
    end

    def return_value
      input_text
    end

    def character_key(keystroke) : Nil
      if keystroke.data.to_s.match character_filter
        super
      end
    end
  end
end
