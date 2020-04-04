module Keimeno
  # macos defaults TERM=xterm-256, and my best guess is that this is
  # based off of "XFree86 xterm."
  #
  # This is the set of escape codes conventionally conveyed by XFree86 xterm
  # when a function key is pressed.
  class FunctionKeys
    MAPPING = {
      "OP" => :f1,
      "OQ" => :f2,
      "OR" => :f3,
      "OS" => :f4,
      "[15~" => :f5,
      "[17~" => :f6,
      "[18~" => :f7,
      "[19~" => :f8,
      "[20~" => :f9,
      "[21~" => :f10,
      "[23~" => :f11,
      "[24~" => :f12,
      "[25~" => :f13,
      "[26~" => :f14,
      "[28~" => :f15,
      "[29~" => :f16,
      "[31~" => :f17,
      "[32~" => :f18,
      "[33~" => :f19,
      "[34~" => :f20,
      "[A" => :up_arrow,
      "[B" => :down_arrow,
      "[D" => :left_arrow,
      "[C" => :right_arrow,
      "[3~" => :delete,

      "a" => :alt_a, "b" => :alt_b, "c" => :alt_c,
      "d" => :alt_d, "e" => :alt_e, "f" => :alt_f,
      "g" => :alt_g, "h" => :alt_h, "i" => :alt_i,
      "j" => :alt_j, "k" => :alt_k, "l" => :alt_l,
      "m" => :alt_m, "n" => :alt_n, "o" => :alt_o,
      "p" => :alt_p, "q" => :alt_q, "r" => :alt_r,
      "s" => :alt_s, "t" => :alt_t, "u" => :alt_u,
      "v" => :alt_v, "w" => :alt_w, "x" => :alt_x,
      "y" => :alt_y, "z" => :alt_z,

      "1" => :alt_1, "2" => :alt_2, "3" => :alt_3,
      "4" => :alt_4, "5" => :alt_5, "6" => :alt_6,
      "7" => :alt_7, "8" => :alt_8, "9" => :alt_9,
      "0" => :alt_0,

      "!" => :alt_1, "@" => :alt_2, "#" => :alt_3,
      "$" => :alt_4, "%" => :alt_5, "$" => :alt_6,
      "&" => :alt_7, "*" => :alt_8, "(" => :alt_9,
      ")" => :alt_0, "`" => :alt_tilde,

      "\t" => :alt_tab, " " => :alt_space, "\r" => :alt_enter,

      "[" => :alt_left_square_bracket, "]" => :alt_right_square_bracket,
      "{" => :alt_left_curly_bracket,  "}" => :alt_right_curly_bracket,

      "." => :alt_period, ">" => :alt_greater_than,
      "," => :alt_comma, "<" => :alt_less_than,
      '"' => :alt_double_quote, "'" => :alt_quote,
    }

    def self.decode_bytes(read_string : String)
      if resolved = MAPPING[read_string.lstrip('\e')]?
        resolved
      else
        :unknown_function
      end
    end
  end
end
