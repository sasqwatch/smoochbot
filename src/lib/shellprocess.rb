require 'open3'

class ShellProcess

  attr_reader :outputs, :stdout, :stderr

  def initialize(port, pretty_print)
    @pp = pretty_print
    server = TCPServer.new port
    t = @pp.print_time_thread("Waiting for shell...")
    @socket = server.accept
    t.kill
    puts ""
    @pp.print_success("Received a connection\n")
    @session_id = "012345"
    @socket.puts "echo #{@session_id}"
    output = ""
    while output.gsub("\r", "").scan(@session_id).length != 1 do
      readable = select([@socket])[0]
      readable.each do |stdio|
        output += stdio.read_nonblock(2**24)
      end
    end
    @pp.print_success("Shell could echo session id!\n")    
    #TODO generate real session id
    @prompt = ""
    @log_file = File.open("./.shell_logs", "w")
    @log_file.sync = true
    @blocking = true
    @output_thread = Thread.new {
      while true do
        readable = select([@socket])[0]
        readable.each do |stdio|
          print stdio.read_nonblock(2**24).gsub("\n","\r\n") unless @blocking
        end
      end
    }
  end

  def close
    @socket.close
  end

  def suppress_shell_prompt
    @socket.puts "export PS1=\"sb \""
    @log_file.puts "export PS1=\"sb \""
    @pp.print_info("Prompt replaced with \"sb \"\n")
    #expects error to be spit out when command isn't found
    @socket.puts ""
    output = ""
    @socket.puts "echo #{@session_id}"
    while output.gsub("\r", "").scan(@session_id).length != 1 do
      readable = select([@socket])[0]
      readable.each do |stdio|
        output += stdio.read_nonblock(2**24)
        #p output
        #p output.gsub("\r", "").scan(@session_id).length
      end
    end
    @log_file.puts "Identify shell prompt: #{output}"
    #confirm prompt
    error_line, @prompt = output.split("\n")
    if !@prompt.nil? then 
      @prompt = nil unless @prompt == error_line[0..@prompt.length-1]
    end
  end

  def input(input)
    #TODO explore using this command to wrap
    #echo hi; echo middle &; echo hi; fg 2>/dev/null; echo hi;
    #input = "echo \"#{@session_id}\"\n" + input + "\necho \"#{@session_id}\""
    @blocking = false
    @log_file.print "INPUT: #{input}: "
    @socket.puts input
  end

  def blocking_input(input)
    @blocking = true
    #TODO explore using this command to wrap
    #echo hi; echo middle &; echo hi; fg 2>/dev/null; echo hi;
    input = "echo \"#{@session_id}\"\n" + input + "\necho \"#{@session_id}\""
    @log_file.print "INPUT: #{input}: "
    @socket.puts input
    output = ""
    #this while loop is waiting for the echos to resolve, and then
    #waits for the prompt to come in so it can chomp it
    #split this into two loops
    while output.gsub("\r", "").scan(@session_id).length != 2 || 
          (!@prompt.nil? && 
             output.gsub("\r", "").scan(@prompt).length != 3) do
      readable = select([@socket])[0]
      readable.each do |stdio|
        new_output = stdio.read_nonblock(2**24) 
        output += new_output
        #expects echo output to be atomic in output
        new_output.gsub!("#{@session_id}\n","") unless new_output.nil?
        new_output.gsub!("\n","\r\n")           unless new_output.nil?
        new_output.gsub!(@prompt,"")            unless new_output.nil? || @prompt.nil?
        @pp.print(new_output)
      end
      #puts "session id count: #{output.scan(@session_id).length}"
      #p output
    end
    @log_file.puts "#{output}"
  end

  def blocking_raw_input(input)
    @blocking = true
    input = "echo \"#{@session_id}\"\n" + input + "\necho \"#{@session_id}\""
    @log_file.print "RAW_INPUT: #{input}: "
    @socket.puts input
    output = ""
    while output.scan(@session_id).length != 2 || 
          (!@prompt.nil? && output.scan(@prompt).length != 3) do
      readable = select([@socket])[0]
      readable.each do |stdio|
        output += stdio.read_nonblock(2**24)
      end
    end
    #p input
    #p output
    #p @prompt
    @log_file.puts "#{output}"
    output.gsub!(@prompt,"")
    output.gsub!("#{@session_id}\n","")
    output
  end
#ShellProcess
end 