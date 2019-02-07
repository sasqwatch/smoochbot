#!/usr/bin/env ruby

require 'tty-prompt'

prompt = TTY::Prompt.new(interrupt: lambda {exit})
prompt.on(:keypress) do |event|
  #p event
  #puts "######################"
  #p prompt.reader.cursor.methods - Object.methods
  #puts "" 
  #puts "######################"
  #p event
  if event.value == "\t"
    #prompt.reader.trigger("\u007f")
  end

  if event.value == "\u007F"
    #puts "\nbackspace pushed"
  end

#  if event.name == :backspace
#    puts "\nbackspace pushed"
#  end

  if event.value == "\u0003"
    exit
  end
end


while true
  input = prompt.ask("> ")
  print `#{input}`
end