#!/usr/bin/env ruby

silent = false
buf = ""
thr = Thread.new { p
  while true do
    sleep 1
    puts "loud" unless silent
    buf += "loud"
  end                  
}

silent = true
sleep 3
silent = false
sleep 3
p buf
exit