class PrettyPrint

  def initialize 
    @Colors = Hash.new
    @Colors[:pink] = "\e[38;5;206m"
    @Colors[:yellow] = "\e[38;5;226m"
    @Colors[:red] = "\e[38;5;9m"
    @Colors[:green] = "\e[38;5;119m"
    @Colors[:blue] = "\e[38;5;39m"
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
#PrettyPrint
end