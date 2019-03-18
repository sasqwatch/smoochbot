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

  def needed_commands(shell, pp, arr_of_cmd_strings = [])
    not_found = shell.raw_input("which tOtAllYn0t4R34lCMD").gsub("tOtAllYn0t4R34lCMD","")
    arr_of_cmd_strings.each do |cmd_str|
      output = shell.raw_input("which #{cmd_str}")
      if output == not_found then
        pp.print_error("CMD: #{cmd_str} not found, aborting\n")
        return false
      end
    end
    true
  end

  def parse(arg_arr)
    #use option_parser to parse arguments
    @option_parser.parse(arg_arr)
  end
#core script
end
