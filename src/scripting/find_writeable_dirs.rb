require_relative "corescript.rb"

class FindWriteableDirs < CoreScript

  def initialize
    keyword = 'fwd'
    description = 'script to find directories writeable by the user'
    @options = Hash.new
    option_parser = OptionParser.new
    option_parser.banner = "Usage: fwd"
      #nicely formatted help message
      puts option_parser
    end
    super(keyword, description, option_parser)
  end

  def run_script(shell, pp, rest_of_line = nil)
    #TODO
  end
#Test  
end
#good link on implementation of option parser
#https://www.thoughtco.com/using-optionparser-2907754

