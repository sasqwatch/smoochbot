require_relative "corescript.rb"

class MoveTools < CoreScript

  def initialize
    keyword = 'movetools'
    description = 'Move all files from the directory'
    @options = Hash.new
    option_parser = OptionParser.new
    option_parser.banner = "Usage: movetools"
    option_parser.on_tail("-h", "--help", "Show this message") do
      #nicely formatted help message
      puts option_parser
    end
    super(keyword, description, option_parser)
  end

  def run_script(shell, pp, rest_of_line = nil)
    #MANDATORY
    #necessary for all scripts
    #arr_of_cmd_strings = ["find"]
    #return unless needed_commands(shell, pp, arr_of_cmd_strings)
    return unless needed_commands(shell, pp)
    #/MANDATORY

    #TODO
  end
#MoveTools
end

