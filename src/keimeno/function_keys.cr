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
      "[3~"  => :delete
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
