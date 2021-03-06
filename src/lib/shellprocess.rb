require 'open3'

class ShellProcess

  attr_reader :outputs, :stdout, :stderr

  def initialize(port, pretty_print)
    @pp = pretty_print
    server = TCPServer.new port
    t = @pp.print_time_thread("Waiting for shell...")
    @socket = server.accept
    #p @socket.methods.sort
    #p @socket.remote_address
    t.kill
    puts ""
    @pp.print_success("Received a connection\n")
    #TODO generate real session id
    @session_id = "0123458899"
    #assume here that bash is in your path
    @socket.puts " exec bash"
    #possible latency issues here? should buffer, needs testing
    @socket.puts "echo #{@session_id}"
    output = ""
    while output.gsub("\r", "").scan(@session_id).length != 1 do
      readable = select([@socket])[0]
      readable.each do |stdio|
          output += stdio.read_nonblock(2**24)
      end
    end
    #puts output
    #shell is in very "fragile" state right now
    #no prompt, can't change it. need to hop into 
    #python shell right away    
    @pp.print_success("Execed into bash temporarily\n")
    #python -c 'import pty; pty.spawn("/bin/bash")'
    @socket.puts "python -c \'import pty; pty.spawn(\"\/bin\/bash\")\'"
    @socket.puts "export SBSESSIONID=\"#{@session_id}\"; echo $SBSESSIONID"
    output = ""
    while output.gsub("\r", "").scan(@session_id).length != 3 do
      readable = select([@socket])[0]
      readable.each do |stdio|
        output += stdio.read_nonblock(2**24)
      end
    end
    #puts output
    @socket.puts "stty raw -echo; echo $SBSESSIONID"
    output = ""
    while output.gsub("\r", "").scan(@session_id).length != 1 do
      readable = select([@socket])[0]
      readable.each do |stdio|
        output += stdio.read_nonblock(2**24)
      end
    end
    #puts output
    @pp.print_success("Successfully moved to a python pty\n")
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
    #assumes there will be no echo of input but prompt could be anything
    #export PS1="sb "
    @socket.puts "export PS1=\"sb \"; echo #{@session_id}"
    @log_file.puts "export PS1=\"sb \"; echo #{@session_id}"
    output = ""
    @prompt = "sb "
    while output.gsub("\r", "").scan(@session_id).length != 1 || 
          output.gsub("\r", "").scan(@prompt).length != 1 do
      readable = select([@socket])[0]
      readable.each do |stdio|
        output += stdio.read_nonblock(2**24)
        #p output
        #p output.gsub("\r", "").scan(@session_id).length
      end
    end
    @pp.print_success("Prompt replaced with \"sb \"\n")
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
    input = "echo \"#{@session_id}\"; " + input + "; echo \"#{@session_id}\""
    @log_file.print "INPUT: #{input}: "
    @socket.puts input
    output = ""
    #this while loop is waiting for the echos to resolve, and then
    #waits for the prompt to come in so it can chomp it
    #split this into two loops
    while output.gsub("\r", "").scan(@session_id).length != 2 || 
          (!@prompt.nil? && 
             output.gsub("\r", "").scan(@prompt).length != 1) do
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
    input = "echo \"#{@session_id}\"; " + input + "; echo \"#{@session_id}\""
    @log_file.print "RAW_INPUT: #{input}: "
    @socket.puts input
    output = ""
    while output.scan(@session_id).length != 2 || 
          (!@prompt.nil? && output.scan(@prompt).length != 1) do
      readable = select([@socket])[0]
      readable.each do |stdio|
        output += stdio.read_nonblock(2**24)
        #puts "=================="
        #puts output
      end
    end
    #p !@prompt.nil? && output.scan(@prompt).length != 3
    #p input
    #p output
    #p @prompt
    @log_file.puts "#{output}"
    output.gsub!(@prompt,"") unless @prompt.nil?
    output.gsub!("#{@session_id}\n","")
    output
  end
#ShellProcess
end 