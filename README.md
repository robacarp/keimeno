# κείμενο - "keímeno" - text

[![Crystal Version](https://img.shields.io/badge/crystal-0.33-blueviolet.svg?longCache=true&style=for-the-badge)](https://crystal-lang.org/)
[![GitHub](https://img.shields.io/github/license/robacarp/mosquito.svg?style=for-the-badge)](https://tldrlegal.com/license/mit-license)

A lightweight and simple, native crystal library for text based interactive command line interfaces (TUI).

[FZF like demo](https://i.imgur.com/DiZ2QQz.gifv)

## Installation

Update your shard.yml to include keymeno

```diff
dependencies:
+  keimeno:
+    github: robacarp/keimeno
```

## Usage

See [the demos](/demo).

A basic command line utility can probably be built using the primitives provided herein: menu, prompt, text input. But that wouldn't be any fun if you were limited to those only.

To build your own interactive utility, subclass `Keimeno::Base`:

```crystal
class CoolMenu < Keimeno::Base
  # The following methods provide high level anchoring into the TUI engine:

  # Display methods are called each time the interface needs to be updated
  def before_display
  end

  def display
  end

  # cleanup method is called (by default) on exit, via ctrl-c or otherwise
  def cleanup
  end

  # return_value is used to emit a result from the interface
  def return_value
  end

  # respond to specific keypresses with methods like these
  def key_ctrl_c
  end

  def key_alt_enter
  end

  # or respond to general keypresses with methods like these
  def key_pressed(keystroke)
  end

  def function_key(keystroke)
  end

  def character_key(keystroke)
  end

  # When you're done and it's time to cleanup and exit cleanly, call `finish!`
  def i_know_im_ready_to_exit
    finish!
  end
end
```

Responding to keypresses can happen at a few different altitudes depending on your needs. If you just want to respond to a special key or two (enter and ESC) and character keys, you might do this:

```crystal
class CoolWidget < Keimeno::Base
  def key_enter
  end

  def key_esc
  end

  def character_key(keystroke)
  end
end
```

For close-to-readline bindings on your user inputs, the `TextInput` or `Prompt` modules can be included and will render a text input at the cursor location which responds reasonably close to what might be expected from a readline interface.

```crystal
class MegaInputDevice < Keimeno::Base
  include Keimeno::TextInput

  def display
    print "What is your favorite color? "
  end

  def key_enter
    finish!
  end

  def return_value
    input_text
  end
end
```
