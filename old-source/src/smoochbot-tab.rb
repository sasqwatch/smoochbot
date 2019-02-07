#!/usr/bin/ruby
require 'Open3'
require 'io/console'
require 'readline'

$pink_prompt = "\e[38;5;206m"
$yellow_prompt = "\e[38;5;226m"
$red_prompt = "\e[38;5;9m"
$default_prompt = "\e[39m"
$shell_prompt_text = "# "
$shell_prompt = $pink_prompt + $shell_prompt_text + $default_prompt
$lwd = Dir.pwd

def beep
	print "\u0007"
end

def cmd_parse cmd, stdin, stdout, stderr	
	#Local commands: lpwd, lls, lcd
	#just enough to move around the file system
	cmd, args = cmd.split(' ', 2)
	args = args.nil? ? "" : args
	case cmd
	when "lpwd"
		#print local wd
		if args != "" then 
			puts "lpwd: too many arguments"
		else
			puts $lwd
		end
	when "lrm"
		#rm local file
		file = args
		ok_flags1 = "-fdPRrvW"
		ok_flags2 = "-idPRrvW"
		if args[0] == '-' then 
			#using flags
			flags, file = args.split(' ', 2)
			clean = true
			flags.each_char do |c|
				clean = clean && ok_flags1.include?(c)
			end
			if !clean then
				clean = true
				flags.each_char do |c|
					clean = clean && ok_flags2.include?(c)
				end
			end
			if clean then 
				if File.exist?(file) then 
					puts `rm #{flags} #{file}`
				else 
					puts "lrm: file/directory doesn't exist #{file}"
				end
			else
				puts "usage: lrm [-f | -i] [-dPRrvW] file"
			end
		else 
			#no flags
			if File.exist?(file) then 
				puts `rm #{file}`
			else 
				puts "lrm: file/directory doesn't exist #{file}"
			end
		end
	when "lls"
		#local ls		
		#sanitize input
		#really not needed, entire thing runs on executing user input
		#that shouldn't need to be sanitized
		#just don't give this a sticky bit and make root the owner... 
		#why you would do that, I don't know
		file = args
		ok_flags = "-ABCFGHLOPRSTUWabcdefghiklmnopqrstuwx1"
		if file[0] == '-' then 
			#using flags
			flags, file = args.split(' ', 2)
			clean = true
			flags.each_char do |c|
				clean = clean && ok_flags.include?(c)
			end
			file = file.nil? ? "." : file
			if clean then 
				if File.exist?(file) then 
					puts `ls #{flags} #{file}`
				else 
					puts "lls: file/directory doesn't exist: #{file}"
				end
			else
				puts "usage: lls [-ABCFGHLOPRSTUWabcdefghiklmnopqrstuwx1] [file ...]"
			end
		else 
			#no flags
			file = file == "" ? "." : file
			if File.exist?(file) then 
				puts `ls #{file}`
			else 
				puts "lls: file/directory doesn't exist: #{file}"
			end
		end
	when "lcd"
		#local cd
		begin
			Dir.chdir(args)
			$lwd = Dir.pwd
		rescue Errno::ENOENT
			puts "lcd: couldn't cd into: " + args
		end
	when "script"
		match_data = /^(.*) (\d+)$/.match(args)
		file = ""
		timeout = 0
		if !match_data.nil? then
			file = match_data[1]
			timeout = match_data[2].to_i
		else
			file = args
		end
		if timeout == 0 then
			puts $yellow_prompt + "No timeout/timeout of 0 means manual script stepping" + $default_prompt
			puts $yellow_prompt + "The first command has already been run" + $default_prompt			
			puts $yellow_prompt + "Press enter to step to the next command..." + $default_prompt			
		end
		if File.exists?(file) then 
			next_command = true
			File.open(file).each do |line|
				puts "\r" + $pink_prompt + "#{line.chomp}" + $default_prompt
				if next_command then stdin.puts line; next_command = false; end
				#this needs a timeout or it will hang on anything 
				#with no stdout or stderr output
				#ready = timeout ? IO.select([stdout, stderr], [], [], timeout) : IO.select([STDIN, stdout, stderr])
				#busy loop, should be refactored
				while !next_command do
					ready = IO.select([STDIN,stdout, stderr], [], [], timeout)
					#monitor timeouts
					next_command = ready.nil? && timeout != 0
					if ready
						readable = ready[0]
					    readable.each do |stdio|
							if stdio == stdout then
						    	output = stdio.read_nonblock(2**24) 
								#stdout formatting
								print "\r" + output
							elsif stdio == stderr then
						    	error_output = stdio.read_nonblock(2**24) 
								#stderr formatting, red output
								print "\r" + $red_prompt + error_output + $default_prompt
							else
								#must be STDIN
						    	output = stdio.read_nonblock(2**24) 
								#if output == "" then puts "newline"; next_command = true end
								next_command = true
								#should consume newline, hacky but turning off echo
								#leaves a password prompt in zsh
								print "\033[F" + "\r"
							end

						end
					end
				end
			end
		else
			puts "usage: script file [timeout]"
		end
	else
		return false
	end
	#if not special case, send command to shell
	return true
end

#puts "\e[38;5;206mHi, I'm smoochbot :)\n\e[39m"
kiss_prompt = $pink_prompt + "K" + $default_prompt + "eep" + $pink_prompt + "              .. ..
"  			+ $pink_prompt + "I" + $default_prompt + "t" + $pink_prompt + "              .'  `  `.
"  			+ $pink_prompt + "S" + $default_prompt + "imple" + $pink_prompt + "        .'_.-...-._`.
"  			+ $pink_prompt + "S" + $default_prompt + "tupid" + $pink_prompt + "         `.       .'
"  			+ $pink_prompt + "*SMOOCH*" + $default_prompt + " :)" + $pink_prompt + "      `-...-'" + $default_prompt

#if (rand(2) == 0) then
if (0 == 0) then
	puts kiss_prompt
else
	puts $pink_prompt + "computer, initiate *SMOOCHING* sequence" + $default_prompt 
	puts "\t\t~Tired Computer User"
end

puts "smoochbot is a wrapper for shell processes"
#practice attaching to process

#loads history file into memory, maybe not the best idea if file gets too big
#might have trouble with portability of Dir.home? hopefully not
history = []
new_cmd_count = 0
if File.exist?(Dir.home + "/.smoochbot_history") then
	#open history file
	File.open(Dir.home + "/.smoochbot_history").each_line do |line|
		history.unshift(line)
	end
else
	#create history file
	puts $yellow_prompt + "History file created at #{Dir.home + "/.smoochbot_history"}" + $default_prompt
end
#probably should open in a+ and read up from bottom of file
#no idea if that's possible, need to look into it
hist_file = File.open(Dir.home + "/.smoochbot_history", "a")
hist_file.sync = true

Open3.popen3("bash") do |stdin, stdout, stderr, thread|
	#pid = thread.pid
	char_reader, char_writer = IO.pipe
	thr = Thread.new {char_writer.puts STDIN.getch; char_writer.close;}
	std = [stdout, stderr, char_reader]
	working_cmd_buffer = ""
	temp_cmd_buffer = ""
	cursor_index = -1
	history_pos = -1
	escaped_buffer = ""
	escaped = false
	print $shell_prompt
    while true do
		begin
			ready = IO.select(std)
		rescue IOError
			#throws an error on an fd closing, just catch it
			#need to handle differentiating between wrapper process fds closing
			#which is bad
			#and char reader closing, which is fine
			#open3 might close the block if that's the case
			#requires testing.
			retry
		end
		if ready
			readable = ready[0]
		    readable.each do |stdio|
				if stdio == stdout then
			    	output = stdio.read_nonblock(2**24) 
					#stdout formatting					
					print "\r" + output.gsub("\n","\r\n") + $shell_prompt
				elsif stdio == stderr then
			    	error_output = stdio.read_nonblock(2**24) 
					#stderr formatting, red output
			    	#puts "catme.txt\ncatroot.txt\ni-left-this-file\nscripts\nsmoochbot\nsmoochbot.backup\ntesting.rb\n"
					print "\r" + $red_prompt + error_output.gsub("\n","\r\n") + $default_prompt + $shell_prompt
				elsif stdio == char_reader					
					begin
						#reading single char from waiting thread
						c = stdio.read_nonblock(2**24).chomp
						escaped = escaped_buffer.length > 2 ? false : escaped
						escaped_buffer = escaped ? escaped_buffer + c : ""
						case c
						when "\u0003" 
		  				#this is to terminate the line
		  				#zsh and fish end nonterminated lines with %	
							print "\r\n" + $pink_prompt + "*SMOOCH*" + $yellow_prompt + " Bye :)" + $default_prompt + "\n" 
							exit
						when ""
							#enter was pressed, process command
							puts "\r\n"
							if working_cmd_buffer == "" then 
								#there was no command
								print $shell_prompt
							else
								if history[0] != working_cmd_buffer then
									hist_file.puts working_cmd_buffer
									history.unshift(working_cmd_buffer)	
								end
								if !(cmd_parse working_cmd_buffer, stdin, stdout, stderr) then
									stdin.puts working_cmd_buffer
									print $shell_prompt
								else 
									print $shell_prompt
								end
								working_cmd_buffer = ""
								temp_cmd_buffer = ""
								history_pos = -1
								cursor_index = -1
							end
						when "\e"
							escaped = true
						when "\t"
							#TODO
							#logic here is a little weird?
							#use first word 
							puts "done"
						when "\u007f"
							clean_buf_size = $shell_prompt_text.length + working_cmd_buffer.length
							print "\r" + " " * clean_buf_size
							if cursor_index >= 0 then working_cmd_buffer[cursor_index] = "" end
							if cursor_index != -1 then cursor_index -= 1 end
							print "\r" + $shell_prompt + working_cmd_buffer
							if cursor_index == -1 then 
								print "\r" + $shell_prompt
							else
								print "\r" + $shell_prompt + working_cmd_buffer[0..cursor_index]
							end
							#puts cursor_index
						else
							#nonspecial char, add to buffer
							if working_cmd_buffer[cursor_index].nil? then 
								working_cmd_buffer += c
							else
								if cursor_index != -1 then
									working_cmd_buffer[cursor_index] += c
								else
									#PREPEND CHAR
									working_cmd_buffer = c + working_cmd_buffer
								end
							end
							cursor_index += 1
							print "\r" + $shell_prompt + working_cmd_buffer
						#	if cursor_index == -1 then 
						#		print "\r" + $shell_prompt
						#	else
							print "\r" + $shell_prompt + working_cmd_buffer[0..cursor_index]
						#	end

						end
						thr.join
						std.pop.close
						char_reader, char_writer = IO.pipe
						std << char_reader
						thr = Thread.new {char_writer.puts STDIN.getch; char_writer.close}
					rescue EOFError
						#do nothing, select heard fd close
					end
					case escaped_buffer #this section needs to be redone so logic is consistent
					when "[A" 
						#p working_cmd_buffer
						escaped = false
						cursor_index -= 2
						working_cmd_buffer[cursor_index..cursor_index + 2] = ""
						history_pos = history[history_pos + 1].nil? ? history_pos : history_pos + 1
						temp_cmd_buffer = history_pos == 0 ? working_cmd_buffer : temp_cmd_buffer
						clean_buf_size = working_cmd_buffer.length + $shell_prompt_text.length
						print "\r" + $shell_prompt + " " * clean_buf_size
						#in the case you have no history in your file
						if history.size != 0 then 
							working_cmd_buffer = history[history_pos].chomp
						end
						print "\r" + $shell_prompt + working_cmd_buffer
					when "[B"
						#down
						escaped = false
						cursor_index -= 2
						puts "\n" + (escaped_buffer.length + 1).to_s

						clean_buf_size = working_cmd_buffer.length + $shell_prompt_text.length
						#working_cmd_buffer = working_cmd_buffer[0..-(escaped_buffer.length + 1)]
						working_cmd_buffer[cursor_index..cursor_index + 2] = ""
						history_pos = history_pos - 1 < -1 ? history_pos : history_pos - 1
						#only way you can jump from history[0] to your temp cmd is if you went up in hist
						#before, meaning temp_cmd_buffer should ALWAYS be set
						working_cmd_buffer = history_pos == -1 ? temp_cmd_buffer : history[history_pos].chomp
						print "\r" + $shell_prompt + " " * clean_buf_size
						print "\r" + $shell_prompt + working_cmd_buffer
					when "[C"
						#right
						escaped = false
						cursor_index -= 2
						clean_buf_size = working_cmd_buffer.length + $shell_prompt_text.length
						#working_cmd_buffer = working_cmd_buffer[0..-(escaped_buffer.length + 1)]
						#working_cmd_buffer[cursor_index..cursor_index + 2] = ""
						working_cmd_buffer[cursor_index + 1..cursor_index + 2] = ""
						print "\r" + $shell_prompt + " " * clean_buf_size
						print "\r" + $shell_prompt + working_cmd_buffer
						cursor_index = cursor_index + 1 < working_cmd_buffer.length ? cursor_index += 1 : cursor_index
						if cursor_index == -1 then 
							print "\r" + $shell_prompt
						else
							print "\r" + $shell_prompt + working_cmd_buffer[0..cursor_index]
						end
					when "[D"
						#left
						escaped = false
						cursor_index -= 2
						clean_buf_size = working_cmd_buffer.length + $shell_prompt_text.length
						working_cmd_buffer[cursor_index + 1..cursor_index + 2] = ""
						print "\r" + $shell_prompt + " " * clean_buf_size
						print "\r" + $shell_prompt + working_cmd_buffer
						if cursor_index != -1 then cursor_index -= 1 end
						if cursor_index == -1 then 
							print "\r" + $shell_prompt
						else
							print "\r" + $shell_prompt + working_cmd_buffer[0..cursor_index]
						end
					else
						#add logging for escaped chars here that I don't handle?
						#add to this in the future
						#need to be careful, this will also catch half complete escape buffers
					end
				end
		    end
	 	end
    end
end

#testing needs to be done with password prompts
#adds same command to history file on new run, shoulnd't double log same command
=begin

# sudo cat catroot.txt
# Password:
<internal:prelude>:76:in `__read_nonblock': Resource temporarily unavailable - read would block (IO::EAGAINWaitReadable)
	from <internal:prelude>:76:in `read_nonblock'
	from ./smoochbot.rb:98:in `block (2 levels) in <main>'
	from ./smoochbot.rb:88:in `each'
	from ./smoochbot.rb:88:in `block in <main>'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.3/usr/lib/ruby/2.3.0/Open3.rb:205:in `popen_run'
	from /System/Library/Frameworks/Ruby.framework/Versions/2.3/usr/lib/ruby/2.3.0/Open3.rb:95:in `popen3'
	from ./smoochbot.rb:79:in `<main>'

#bug with multiple inputs to ls, shouldnt have that enter
# lls test space
ls: space: No such file or directory
ls: test: No such file or directory

# lls test space


=end