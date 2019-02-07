#!/usr/bin/ruby

require 'io/console'
require 'tty-prompt'

prompt = TTY::Prompt.new(interrupt: lambda {exit})
p prompt.reader.methods - Object.methods
p prompt.reader.cursor
p prompt.ask("test")

while true
  c = STDIN.getch
  `c`
  exit if c == "\u0003"
end

#\e[3~ is delete