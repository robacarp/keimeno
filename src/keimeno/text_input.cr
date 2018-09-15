module Keimeno::TextInput
  getter text_buffer = [] of Char
  getter input_text = ""

  private def build_input_text : Nil
    @input_text = text_buffer.join("")
  end

  def set_input_text(data : String) : Nil
    @text_buffer = data.each_char.to_a
    build_input_text
  end

  def key_backspace : Nil
    text_buffer.pop if text_buffer.any?
    build_input_text
  end

  def character_key(keystroke) : Nil
    text_buffer << keystroke.data
    build_input_text
  end

  def show_input
    print input_text
  end
end
