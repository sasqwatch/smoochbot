#!/usr/bin/env ruby

require 'readline'

#tab complete
comp = proc do |s|
  directory_list = Dir.glob("#{s}*")
  if directory_list.size > 0
    directory_list
  else
    Readline::HISTORY.grep(/^#{Regexp.escape(s)}/)
  end
end

#local priv level most basic check
prompt = `whoami`.chomp == "root" ? "# " : "$ "

#this is a blocking call
while input = Readline.readline(prompt, true)
  break                       if input == "exit"
  puts Readline::HISTORY.to_a if input == "hist"
  # Remove blank lines from history
  Readline::HISTORY.pop if input == ""
  #hangs here on sudo
  system(input)
end

