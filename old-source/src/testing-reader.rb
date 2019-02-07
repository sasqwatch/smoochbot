#!/usr/bin/env ruby

require 'tty-prompt'

reader = TTY::Reader.new

c = reader.read_char

p c