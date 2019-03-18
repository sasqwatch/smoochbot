#!/usr/bin/env ruby

require_relative "lib/prettyprint"

pp = PrettyPrint.new

syringe = "┣────▇▇▇▇▇▇▇▇═─── Shell\n" 
lead = "┣────" 
tail = "═─── Shell" 
liquid = "▇▇▇▇▇▇▇▇" 
liquid1 = "▇▇" 
liquid2 = "▇▇" 
liquid3 = "▇▇" 
liquid4 = "▇▇" 


print "\r"
print lead
pp.print(liquid1, :blue)
pp.print(liquid2, :blue)
pp.print(liquid3, :blue)
pp.print(liquid4, :blue)
print tail
sleep(0.4)

print "\r"
print lead
pp.print(liquid1)
pp.print(liquid2, :blue)
pp.print(liquid3, :blue)
pp.print(liquid4, :blue)
print tail
sleep(0.4)

print "\r"
print lead
pp.print(liquid1)
pp.print(liquid2)
pp.print(liquid3, :blue)
pp.print(liquid4, :blue)
print tail
sleep(0.4)

print "\r"
print lead
pp.print(liquid1)
pp.print(liquid2)
pp.print(liquid3)
pp.print(liquid4, :blue)
print tail
sleep(0.4)


print "\r"
print lead
pp.print(liquid1)
pp.print(liquid2)
pp.print(liquid3)
pp.print(liquid4)
print tail
sleep(0.4)
