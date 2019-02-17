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
    @log_file = File.open("./shell_logs", "w")
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
    @pp.print_success("Recieved a connection\n")
  end

  def identify_shell_prompt
    #expects error to be spit out when command isn't found
    @stdin.puts ""
    output = ""
    @stdin.puts "#{@session_id} 2>&1"
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
    input = "echo \"#{@session_id}\";" + input + ";echo \"#{@session_id}\""
    @stdin.puts input
    output = ""
    while output.scan(@session_id).length != 2 || 
          (!@prompt.nil? && output.scan(@prompt).length != 1) do
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
    end
    @log_file.puts "INPUT: #{input}: #{output}"
  end

  def raw_input(input)
    input = "echo \"#{@session_id}\";" + input + ";echo \"#{@session_id}\""
    @stdin.puts input
    output = ""
    while output.scan(@session_id).length != 2 || 
          (!@prompt.nil? && output.scan(@prompt).length != 1) do
      readable = select(@outputs)[0]
      readable.each do |stdio|
        output += stdio.read_nonblock(2**24)
      end
    end

    @log_file.puts "INPUT_RAW: #{input}: #{output}"
    output.gsub!(@prompt,"")
    output.gsub!("#{@session_id}\n","")
    output
  end
#ShellProcess
end