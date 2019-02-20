require_relative "corescript.rb"

class FixPath < CoreScript

  def initialize
    keyword = 'fp'
    description = 'attempt to fix path environment'
    @options = Hash.new
    option_parser = OptionParser.new
    option_parser.banner = "Usage: fp"
    option_parser.on_tail("-h", "--help", "Show this message") do
      #nicely formatted help message
      puts option_parser
    end
    super(keyword, description, option_parser)
  end

  def run_script(shell, pp, rest_of_line = nil)
    #MANDATORY
    #necessary for all scripts
    return unless which_commands(shell, pp) 
    #/MANDATORY

    which_commands(shell, pp)
    path = ""
    path += "/usr/local/bin"
    path += ":"
    path += "/usr/bin"
    path += ":"
    path += "/bin"
    path += ":"
    path += "/usr/sbin"
    path += ":"
    path += "/sbin"
    path += ":"
    path += "/opt/local/bin"
    #shouldn't mess with anything, at worse adds a dir
    #that aready exists in path or one that doesn't exist
    shell.raw_input("export $PATH=$PATH:#{path}")
    pp.print_info("Added common directories to $PATH\n")

  end
#FixPath
end

