require_relative "corescript.rb"

class FindTools < CoreScript

  def initialize
    keyword = 'ft'
    description = 'find available tools'
    @options = Hash.new
    option_parser = OptionParser.new
    option_parser.banner = "Usage: ft"
    option_parser.on_tail("-h", "--help", "Show this message") do
      #nicely formatted help message
      puts option_parser
    end
    super(keyword, description, option_parser)
  end

  def run_script(shell, pp, rest_of_line = nil)
    #MANDATORY
    #necessary for all scripts
    arr_of_cmd_strings = ["which"]
    return unless needed_commands(shell, pp, arr_of_cmd_strings)
    #/MANDATORY

    #debate is to use these methods over current methods
    #this is more thorough but takes way longer on huge 
    #file systems and not really necessary 99.99% of the time
    #can be run manually anyways and updated through manual 
    #update function

    #shell.raw_input("find / -name nc")

    #common exploit languages, would be happy to add more
    #submit an issue if needed
    #TODO add ability to look for flags
    #example: nc -e

    tools = []
    tools << "nc"
    tools << "wget"
    tools << "fetch"
    tools << "netcat"
    tools << "tftp"
    tools << "ftp"
    tools << "curl"
    #TODO
    #if this exists god help you.
    #replace with session ID later
    tmp = shell.blocking_raw_input("which tOtAllYn0t4R34lT00L")
    not_found = tmp.gsub("tOtAllYn0t4R34lT00L","")
    tools.each do |tool|
      tmp2 = shell.blocking_raw_input("which #{tool}")
      output = tmp2.gsub("#{tool}","")
      pp.print_info("#{tool} is available\n") unless output == not_found
    end
  end
#FindTools
end

