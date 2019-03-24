require_relative "corescript.rb"

class SUIDBitCheck < CoreScript

  def initialize
    keyword = 'suidbitcheck'
    description = 'Looks for common SUID privilege escalation binaries'
    @options = Hash.new
    option_parser = OptionParser.new
    option_parser.banner = "Usage: suidbitcheck"
    option_parser.on_tail("-h", "--help", "Show this message") do
      #nicely formatted help message
      puts option_parser
    end
    super(keyword, description, option_parser)
  end

  def run_script(shell, pp, rest_of_line = nil)
    #MANDATORY
    #necessary for all scripts
    arr_of_cmd_strings = ["find"]
    return unless needed_commands(shell, pp, arr_of_cmd_strings)
    #/MANDATORY

    t = pp.print_time_thread("Searching for SUID binaries")
    
    interesting_list = []
    interesting_list << "nmap"
    interesting_list << "vim"
  
    suid_list_str = shell.blocking_raw_input("find / -user root -perm -4000 -print 2>/dev/null")
    sep = suid_list_str[-2..-1] == "\r\n" ? "\r\n" : "\n"
    suid_list = suid_list_str.chomp("#{sep}").split("#{sep}").uniq
    t.kill
    puts ""
    found = false
    suid_list.each do |path_to_binary|
      interesting_list.each do |interesting_binary|
        if path_to_binary.split("/")[-1] == interesting_binary then
          found = true
          pp.print_esc("#{path_to_binary} has it's SUID bit set and is owned by root, possible privilege escalation\n")
        end
      end
    end
    pp.print_error("Found no interesting SUID binaries\n") unless found
  end
#SUIDBitCheck
end
