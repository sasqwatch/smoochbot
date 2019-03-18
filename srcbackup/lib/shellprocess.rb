require 'open3'

class ShellProcess

  attr_reader :outputs, :stdout, :stderr

  def initialize(process_start_string, pretty_print, start_dir = Dir.pwd)
    @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(process_start_string,
                                                       :chdir=>start_dir
                                                      )
    @pid = @wait_thr.pid
    @outputs = [@stdout, @stderr]
    #TODO generate real session id
    @session_id = "012345"
    @pp = pretty_print
    @prompt = ""
    @log_file = File.open("./.shell_logs", "w")
    @log_file.sync = true
  end

  def close
    @stdin.close
    @stdout.close
    @stderr.close
    @wait_thr.value  # Process::Status object returned.
  end

  def listeners
    [@stdout, @stderr]
  end

  def listeners
    [@stdout, @stderr]
  end

  def verify_connection
    #expects error to be spit out when command isn't found
    @stdin.puts "#{@session_id} 2>&1"
    output = ""
    t = @pp.print_time_thread("Waiting for shell...")
    while output.scan(/#{@session_id}/).length != 1 do
      readable = select(@outputs)[0]
      readable.each do |stdio|
        output += stdio.read_nonblock(2**24)
      end
    end
    #first command should be nonexistant session id
    #shell is listening
    t.kill
    puts ""
    @pp.print_success("Received a connection\n")
  end

  def identify_shell_prompt
    #expects error to be spit out when command isn't found
    @stdin.puts ""
    output = ""
    @stdin.puts "echo #{@session_id}"
    while output.scan(@session_id).length != 1 do
      readable = select(@outputs)[0]
      readable.each do |stdio|
        output += stdio.read_nonblock(2**24)
      end
    end
    @log_file.puts "Identify shell prompt: #{output}"
    #confirm prompt
    error_line, @prompt = output.split("\n")
    if !@prompt.nil? then 
      @prompt = nil unless @prompt == error_line[0..@prompt.length-1]
    end
    #at this point prompt will be either nil or the best guess  
    @pp.print_info("No shell prompt found\n") if @prompt.nil?
    @pp.print_info("Shell prompt found: #{@prompt}\n") unless @prompt.nil?
    @pp.print_info("This prompt will be removed from now on\n") unless @prompt.nil?
  end

  def input(input)
    #TODO explore using this command to wrap
    #echo hi; echo middle &; echo hi; fg 2>/dev/null; echo hi;
    input = "echo \"#{@session_id}\"\n" + input + "\necho \"#{@session_id}\""
    @log_file.print "INPUT: #{input}: "
    @stdin.puts input
    output = ""
    #this while loop is waiting for the echos to resolve, and then
    #waits for the prompt to come in so it can chomp it
    #split this into two loops
    while output.scan(@session_id).length != 2 || 
          (!@prompt.nil? && output.scan(@prompt).length != 3) do
      readable = select(@outputs)[0]
      readable.each do |stdio|
        new_output = stdio.read_nonblock(2**24) 
        output += new_output
        #expects echo output to be atomic in output
        new_output.gsub!("#{@session_id}\n","") unless new_output.nil?
        new_output.gsub!("\n","\r\n")           unless new_output.nil?
        new_output.gsub!(@prompt,"")            unless new_output.nil? || @prompt.nil?
        @pp.print(new_output)                   if stdio == @stdout
        @pp.print(new_output, :red)             if stdio == @stderr
      end
      puts "session id count: #{output.scan(@session_id).length}"
      p output
    end
    @log_file.puts "#{output}"
  end

  def blocking_input(input)
    #TODO explore using this command to wrap
    #echo hi; echo middle &; echo hi; fg 2>/dev/null; echo hi;
    input = "echo \"#{@session_id}\"\n" + input + "\necho \"#{@session_id}\""
    @log_file.print "INPUT: #{input}: "
    @stdin.puts input
    output = ""
    #this while loop is waiting for the echos to resolve, and then
    #waits for the prompt to come in so it can chomp it
    #split this into two loops
    while output.scan(@session_id).length != 2 || 
          (!@prompt.nil? && output.scan(@prompt).length != 3) do
      readable = select(@outputs)[0]
      readable.each do |stdio|
        new_output = stdio.read_nonblock(2**24) 
        output += new_output
        #expects echo output to be atomic in output
        new_output.gsub!("#{@session_id}\n","") unless new_output.nil?
        new_output.gsub!("\n","\r\n")           unless new_output.nil?
        new_output.gsub!(@prompt,"")            unless new_output.nil? || @prompt.nil?
        @pp.print(new_output)                   if stdio == @stdout
        @pp.print(new_output, :red)             if stdio == @stderr
      end
      puts "session id count: #{output.scan(@session_id).length}"
      p output
    end
    @log_file.puts "#{output}"
  end


  def raw_input(input)
    input = "echo \"#{@session_id}\"\n" + input + "\necho \"#{@session_id}\""
    @log_file.print "RAW_INPUT: #{input}: "
    @stdin.puts input
    output = ""
    while output.scan(@session_id).length != 2 || 
          (!@prompt.nil? && output.scan(@prompt).length != 3) do
      readable = select(@outputs)[0]
      readable.each do |stdio|
        output += stdio.read_nonblock(2**24)
      end
    end
    @log_file.puts "#{output}"
    output.gsub!(@prompt,"")
    output.gsub!("#{@session_id}\n","")
    output
  end
#ShellProcess
end 