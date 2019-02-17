require 'optparse'

class CoreScript

  attr_reader :keyword, :description, :option_parser
  
  def initialize(keyword, description, option_parser)
    #keyword to invoke script
    @keyword = keyword
    #description of core script
    @description = description
    #OptionParser object created by script
    @option_parser = option_parser
  end

  def inspect
    "Command: #{@keyword}, Description: #{@description}"
  end

  def run_script(shell, pp, rest_of_line = nil)
    raise NotImplementedError, "subclass did not define #run_script"
  end

  def parse(arg_arr)
    #use option_parser to parse arguments
    @option_parser.parse(arg_arr)
  end
#core script
end
