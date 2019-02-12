class PrettyPrint

  def initialize 
    @Colors = Hash.new
    @Colors[:pink] = "\e[38;5;206m"
    @Colors[:yellow] = "\e[38;5;226m"
    @Colors[:seafoam] = "\e[38;5;121m"
    @Colors[:purple] = "\e[38;5;63m"
    @Colors[:red] = "\e[38;5;9m"
    @Colors[:green] = "\e[38;5;119m"
    @Colors[:blue] = "\e[38;5;39m"
    @Colors[:info_blue] = "\e[38;5;75m"
    @Colors[:file_red] = "\e[38;5;196m"
    @Colors[:default] = "\e[39m"
  end

  def print(string, color = :default)
    $stdout.print @Colors[color] + string + @Colors[:default]
  end

  def puts(string, color = :default)
    $stdout.puts @Colors[color] + string + @Colors[:default]
  end

  def color(string, color = :default)
    @Colors[color] + string + @Colors[:default]
  end

  def print(string, color = :default)
    $stdout.print @Colors[color] + string + @Colors[:default]
  end

  def print_info(string)
    pre = @Colors[:info_blue]
    pre += "[*] " 
    pre += @Colors[:default]
    $stdout.print pre + string + @Colors[:default]
  end

  def print_success(string)
    pre = @Colors[:green]
    pre += "[+] " 
    pre += @Colors[:default]
    $stdout.print pre + string + @Colors[:default]
  end

  def print_error(string)
    pre = @Colors[:red]
    pre += "[-] " 
    pre += @Colors[:default]
    $stdout.print pre + string + @Colors[:default]
  end

  def print_time_thread(string)
    Thread.new {
      time_piece = nil
      while true do
        case time_piece
        when nil
          time_piece = "|"
        when "|"
          time_piece = "/"
        when "/"
          time_piece = "-"
        when "-"
          time_piece = "\\"
        when "\\"
          time_piece = "|"
        end
        pre = @Colors[:info_blue]
        pre += "[#{time_piece}] " 
        pre += @Colors[:default]
        $stdout.print "\r" + pre + string + @Colors[:default]
        sleep(0.2)
      end
    }
  end
#PrettyPrint
end