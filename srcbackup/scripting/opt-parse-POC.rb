#!/usr/bin/env ruby

require 'optparse'

ARGV << '-h' if ARGV.empty?
options = {}

opts = OptionParser.new
opts.banner = "Usage: calc.rb [options]"

opts.on("-l", "--length L", Integer, "Length") { |l| options[:length] = l }
opts.on("-w", "--width W", Integer, "Width") { |w| options[:width] = w }

opts.on_tail("-h", "--help", "Show this message") do
  puts opts
  exit
end

tmp = ["-l", "10"]
opts.parse!(tmp)

puts opts
p options
p tmp

puts "test test2    tst3".split