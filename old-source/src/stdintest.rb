#!/usr/bin/env ruby

require 'io/console'

while true
  begin
    #p STDIN.read_nonblock(1)
    p STDIN.getch
  rescue IO::EAGAINWaitReadable

  end
end

#Documents/smoochbot/src/stdintest.rb