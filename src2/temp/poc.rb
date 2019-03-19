#!/usr/bin/env ruby


a = [0,1]

 p a[1]
 p a.shift
 p a.shift == nil

exit
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