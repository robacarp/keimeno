require "../src/keimeno"

class HelloWorld < Keimeno::Prompt
end

hello = HelloWorld.new "What is your name?"
name = hello.run
puts
puts "Hello #{name}!"

