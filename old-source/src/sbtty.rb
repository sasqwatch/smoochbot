#!/usr/bin/env ruby

require 'tty-prompt'
require_relative "prettyprint"

Prompts = {true => "#", false => "$"}
root = false

pp = PrettyPrint.new
prompt = TTY::Prompt.new(interrupt: lambda {})
prompt.on(:keypress) do |event|
  if event.value == "\u0003"
    puts "\ni caught the ctrl c key" 
    exit
  end

  if event.value == "c"
    puts "\ni caught the c key" 
  end

  if event.value == :f22
    #switch prompt from root to user
    root = false
  end

  if event.value == :f23
    #switch prompt from user to root
    root = true
  end

  if event.value == :f24
    #refresh prompt
  end
end

File.open(Dir.home + "/.smoochbot_history").each_line do |line|
  prompt.reader.add_to_history(line.chomp)
end

while true
  puts prompt.ask(pp.color(Prompts[root], :pink))
end

