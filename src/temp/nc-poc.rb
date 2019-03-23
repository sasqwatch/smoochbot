#!/usr/bin/env ruby

require 'socket'

server = TCPServer.new 4445
client = server.accept    # Wait for a client to connect

t = Thread.new {
  while true do
    readable = select([client])[0]
    readable.each do |stdio|
      print stdio.read_nonblock(2**24)
    end
  end
}

while true
  i = gets
  client.puts i
end
client.close
