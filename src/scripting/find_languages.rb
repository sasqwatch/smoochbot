require_relative "corescript.rb"

class FindLanguages < CoreScript

  def initialize
    keyword = 'fl'
    description = 'find available programming languages'
    @options = Hash.new
    option_parser = OptionParser.new
    option_parser.banner = "Usage: fl"
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

    #debate is to use these methods over current methods
    #this is more thorough but takes way longer on huge 
    #file systems and not really necessary 99.99% of the time
    #can be run manually anyways and updated through manual 
    #update function

    #shell.raw_input("find / -name perl*")
    #shell.raw_input("find / -name python*")
    #shell.raw_input("find / -name gcc*")
    #shell.raw_input("find / -name cc")

    #common exploit languages, would be happy to add more
    #submit an issue if needed
    languages = []
    languages << "perl"
    languages << "python"
    languages << "ruby"
    languages << "gcc"
    languages << "cc"
    #TODO
    #replace with session ID later
    #if this exists god help you.
    #maybe do redirect of stderr
    not_found = shell.blocking_raw_input("which tOtAllYn0t4R34lCMD").gsub("tOtAllYn0t4R34lCMD","")
    languages.each do |language|
      #even if in root dir, will still have / in name
      output = shell.blocking_raw_input("which #{language}").gsub("#{language}","")
      pp.print_info("#{language.capitalize} is available\n") unless output == not_found
    end
  end
#FindLanguages
end

