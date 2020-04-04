module Keimeno::TextInput
  getter text_buffer = [] of Char

  def input_text
    text_buffer.join("")
  end

  private property input_cursor_position = 0
  private getter word_boundaries_invalid = true
  @word_boundaries = [] of Int32

  def set_input_text(data : String) : Nil
    @text_buffer = data.each_char.to_a
    @input_cursor_position = text_buffer.size
  end

  def key_backspace : Nil
    return unless input_cursor_position > 0
    text_buffer.delete_at input_cursor_position - 1
    decrement_cursor_position
    invalidate_word_boundaries!
  end

  def character_key(keystroke) : Nil
    text_buffer.insert input_cursor_position, keystroke.data
    increment_cursor_position
    invalidate_word_boundaries!
  end

  private def increment_cursor_position
    return if input_cursor_position >= text_buffer.size
    @input_cursor_position += 1
  end

  private def decrement_cursor_position
    return if input_cursor_position <= 0
    @input_cursor_position -= 1
  end

  private def set_input_cursor(@input_cursor_position)
  end

  def key_right_arrow
    increment_cursor_position
  end

  def key_left_arrow
    decrement_cursor_position
  end

  def key_ctrl_a
    set_input_cursor 0
  end

  def key_ctrl_e
    set_input_cursor text_buffer.size
  end

  def key_ctrl_b
    decrement_cursor_position
  end

  def key_ctrl_f
    increment_cursor_position
  end

  def key_ctrl_w : Nil
    destination = previous_word_boundary
    length = input_cursor_position - destination
    text_buffer.delete_at destination, length
    set_input_cursor destination
    invalidate_word_boundaries!
  end

  def key_alt_d
    destination = next_word_boundary
    length = destination - input_cursor_position

    return unless length > 0

    text_buffer.delete_at input_cursor_position, length
    invalidate_word_boundaries!
  end

  def key_alt_b
    set_input_cursor previous_word_boundary
  end

  def key_alt_f
    set_input_cursor(next_word_boundary - 1)
  end

  def key_ctrl_u
    text_buffer.delete_at 0, input_cursor_position
    set_input_cursor 0
  end

  def key_ctrl_k
    length = text_buffer.size - input_cursor_position
    text_buffer.delete_at input_cursor_position, length
  end

  private def previous_word_boundary : Int32
    destination_index = word_boundaries.index do |boundary|
      input_cursor_position <= boundary
    end

    destination_index = 0 if destination_index.nil?
    destination_index -= 1 if destination_index > 0
    word_boundaries[destination_index]
  end

  private def next_word_boundary : Int32
    # find the first word boundary that is after the cursor
    destination_index = word_boundaries.index do |boundary|
      input_cursor_position + 1 < boundary - 1
    end

    # if no word boundary exists after the cursor, take the last one
    destination_index = word_boundaries.size - 1 if destination_index.nil?

    # the destination should be the space before the word boundary
    #   unless the destination is the end of the string
    if destination_index == word_boundaries.size - 1
      word_boundaries[destination_index]
    else
      word_boundaries[destination_index] - 1
    end
  end

  private def word_boundaries
    return @word_boundaries unless word_boundaries_invalid

    boundary_regex = /\b(?=\w)/
    @word_boundaries = input_text
      .split(boundary_regex)
      .each_with_object([0]) do |chunk, boundaries|
        last_boundary = boundaries[-1]
        boundaries.push last_boundary + chunk.size
      end

    @word_boundaries_invalid = false
    @word_boundaries
  end

  private def invalidate_word_boundaries!
    @word_boundaries_invalid = true
  end

  def show_input
    hide_cursor
    print input_text
    # text_buffer.each_with_index do |char, index|
    #   color = ""
    #   if word_boundaries.includes? index
    #     color = "\033[30;41m"
    #   end

    #   if index == input_cursor_position
    #     color = "\033[30;42m"
    #   end
    #   print "#{color}#{char}\033[0m"
    # end

    bump_cursor col: (input_cursor_position - text_buffer.size)
    show_cursor
  end
end
