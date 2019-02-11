require 'open3'

class ShellProcess

  attr_reader :outputs, :stdout, :stderr

  def initialize(process_start_string, pretty_print, start_dir = Dir.pwd)
    @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(process_start_string,
                                                       :chdir=>start_dir
                                                      )
    @pid = @wait_thr.pid
    @outputs = [@stdout, @stderr]
    @session_id = "012345"
    @pp = pretty_print
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

  def input(input)
    input = "echo \"#{@session_id}\";" + input + ";echo \"#{@session_id}\""
    @stdin.puts input
    output = ""
    while output.scan(/#{@session_id}/).length != 2 do
      readable = select(@outputs)[0]
      readable.each do |stdio|
        new_output = stdio.read_nonblock(2**24) 
        new_output.gsub!("\n","\r\n") unless new_output.nil?
        @pp.print(new_output, :purple)       if stdio == @stdout
        @pp.print(new_output, :red) if stdio == @stderr
        output += new_output
      end
    end
  end
#ShellProcess
end