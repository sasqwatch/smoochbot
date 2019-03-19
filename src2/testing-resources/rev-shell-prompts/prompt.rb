#!/usr/bin/env ruby

require 'socket'

s = TCPSocket.new 'localhost', 4445

while true
  s.print "prompt$ "   
  s.gets        
end

