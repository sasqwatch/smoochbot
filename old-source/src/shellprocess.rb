class ShellProcess

  def initialize(process_start_string, start_dir = Dir.pwd)
    @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(process_start_string,
                                                       :chdir=>start_dir
                                                      )
    @pid = @wait_thr.pid
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

  def stdout
    @stdout
  end

  def stderr
    @stderr
  end

  def input(input)
    @stdin.puts input
  end
#ShellProcess
end