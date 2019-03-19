require_relative "corescript.rb"

class UpgradeToPythonTTY < CoreScript

  def initialize
    keyword = 'us'
    description = 'ugrade shell to python tty'
    @options = Hash.new
    option_parser = OptionParser.new
    option_parser.banner = "Usage: us"
    option_parser.on_tail("-h", "--help", "Show this message") do
      #nicely formatted help message
      puts option_parser
    end
    super(keyword, description, option_parser)
  end

  def run_script(shell, pp, rest_of_line = nil)
    #MANDATORY
    #necessary for all scripts
    #return unless needed_commands(shell, pp, arr_of_cmd_strings)
    return unless needed_commands(shell, pp)
    #/MANDATORY

    #TODO
    #same debate as find languages

    #TODO
    #replace with session ID later
    #if this exists god help you.
    not_found = shell.raw_input("which tOtAllYn0t4R34lCMD").gsub("tOtAllYn0t4R34lCMD","")
    #even if in root dir, will still have / in name
    output = shell.raw_input("which python").gsub("python","")
    continue = output == not_found
    pp.print_error("Python not found, can't upgrade to tty") unless continue
    return unless continue
    
  end
#UpgradeToPythonTTY
end

