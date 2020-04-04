require "../src/keimeno"
require "option_parser"

class DirectoryNavigator < Keimeno::Menu
  RULE = "------------------------------------"

  getter current_dir

  def initialize(@base_dir : String)
    @current_dir = Dir.new @base_dir
    @heading = ""
    @options = [] of String

    repopulate_options
  end

  def return_value
    @current_dir.path
  end

  def repopulate_options : Array(String)
    @options = @current_dir.children.select do |path|
      File.info(File.join @current_dir.path, path).directory?
    end.sort
  end

  def key_enter
    super

    # If a subdirectory was chosen
    if finished? && (choice_ = choice)
      switch_directory choice_
      self.finished = false
      self.cursor_position = -1
    end
  end

  def switch_directory(new_path : String)
    @current_dir = Dir.new(
        File.real_path(
          File.join @current_dir.path, new_path
        )
      )
    repopulate_options
    set_input_text ""
  end

  def display
    puts "Searching in #{@current_dir.path} :"
    puts formatted_options
    puts

    if cursor_active?
      puts "ENTER		Navigate to directory".colorize.bold
    else
      if matches.size == 1
        puts "ENTER		Navigate to directory".colorize.bold
      else
        puts "ENTER		Navigate to directory".colorize.dim
      end
    end

    if cursor_active? || matches.size == 1
      selected = "selected".colorize.bold
      puts "^d		Choose #{selected} directory"
    else
      puts "^d		Choose this directory"
    end

    puts "ESC		Clear filter"

    puts "^p		Navigate up (..)"
    puts "^n		Create Directory"
    puts "↑ / ↓		Manually select Directory"
    puts RULE
    print "Filter: "
    print input_text
  end

  # Navigate up one level
  def key_ctrl_p
    # A poor hack to prevent navigating up past the initial directory
    if @current_dir.path.size > @base_dir.size
      switch_directory ".."
    end
  end

  # Create a new directory
  def key_ctrl_n
    new_directory_name = ""
    clear

    maintain_saved_cursor do
      new_directory_name = Keimeno::Prompt.new(
        "Create new directory in #{@current_dir.path}:"
      ).run
    end

    return if new_directory_name.size == 0
    return if new_directory_name == "."
    return if new_directory_name == ".."

    Dir.mkdir( File.join @current_dir.path, new_directory_name )

    switch_directory new_directory_name
  end

  # Choose a directory and finish
  def key_ctrl_d
    return if ! cursor_active? && matches.size > 1

    if cursor_active?
      switch_directory options[cursor_position]
    elsif matches.size == 1
      switch_directory matches.first.text
    end

    finish!
  end
end

#### main
directory = Dir.current

parser = OptionParser.new do |parser|
  parser.banner = "Usage: #{PROGRAM_NAME} [placement dir]"

  parser.on("-h", "This is help.") do
    STDERR.puts parser
    exit 1
  end

  parser.unknown_args do |files|
    if files.any?
      directory = files.first
    end
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit 1
  end
end

parser.parse

navigator = DirectoryNavigator.new(directory)
navigator.full_screen = true
chosen_directory = navigator.run

puts "You chose #{chosen_directory}"
