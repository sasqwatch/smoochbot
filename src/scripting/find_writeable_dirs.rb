require_relative "corescript.rb"

class FindWriteableDirs < CoreScript

  def initialize
    keyword = 'fwd'
    description = 'script to find directories writeable by the user'
    @options = Hash.new
    option_parser = OptionParser.new
    option_parser.banner = "Usage: fwd"
    option_parser.on_tail("-h", "--help", "Show this message") do
      #nicely formatted help message
      puts option_parser
    end
    super(keyword, description, option_parser)
  end

  def warn_user(pp, dir_list, warned)
    continue = true
    if dir_list.flatten.uniq.length >= 25 && !warned then
      warned = true
      pp.print_warning("Found at least 25 unique writeable directories, continue? (y/n)\n")
      loop do
        answer = $stdin.getch
        case answer
        when "y"
          #continue with blocking read like normal
          pp.print_info("Resuming\n")
          break
        when "n"
          #stop looking for dirs
          continue = false
          break
        else
          pp.print_warning("Please enter y or n\n")
        end
      end 
    end
    return continue, warned
  end

  def find_user_writeable(shell, pp, user, warned)
    dir_list = []
    t = pp.print_time_thread("Finding dirs writeable by User: #{user}")
    cmd =  "find / \'(\' -type d \')\'"
    cmd += " \'(\' -user #{user} -perm -u=w \')\' 2>/dev/null"
    dir_list_str = shell.raw_input(cmd)
    sep = dir_list_str[-2..-1] == "\r\n" ? "\r\n" : "\n"
    dir_list << dir_list_str.chomp("#{sep}").split("#{sep}").uniq
    t.kill
    print "\r"
    pp.clear_line
    pp.print_success("Found #{dir_list.flatten.length} dirs writeable for this user\n") if dir_list.flatten.length > 1
    pp.print_success("Found #{dir_list.flatten.length} dir writeable for this user\n") if dir_list.flatten.length == 1
    pp.print_error("Found #{dir_list.flatten.length} dirs writeable for this user\n") if dir_list.flatten.length == 0
    continue, warned = warn_user(pp, dir_list, warned)
    return dir_list, continue, warned
  end

  def find_groups_writeable(shell, pp, groups, warned)
    dir_list = []
    continue = true
    groups.split(" ").each.with_index do |group,i|
      pp.print_info("Finding dirs writeable by group: #{group}\n")
      t = pp.print_time_thread("group #{i+1}/#{groups.split(" ").length}...")
      cmd =  "find / \'(\' -type d \')\'"
      cmd += " \'(\' -group #{group} -perm -g=w \')\'"
      dir_list_str = shell.raw_input(cmd)
      sep = dir_list_str[-2..-1] == "\r\n" ? "\r\n" : "\n"
      #99% sure unique not needed
      group_dir_list = dir_list_str.chomp("#{sep}").split("#{sep}").uniq
      #TODO make this length a flag
      t.kill
      print "\r"
      pp.clear_line
      pp.print_success("Found #{group_dir_list.flatten.length} dirs writeable for this group\n") if group_dir_list.flatten.length > 1
      pp.print_success("Found #{group_dir_list.flatten.length} dir writeable for this group\n") if group_dir_list.flatten.length == 1
      pp.print_error("Found #{group_dir_list.flatten.length} dirs writeable for this group\n") if group_dir_list.flatten.length == 0
      dir_list << group_dir_list
      continue, warned = warn_user(pp, dir_list, warned)
      break unless continue
    end
    return dir_list, continue, warned
  end

  def find_world_writeable(shell, pp, warned)
    dir_list = []
    t = pp.print_time_thread("Finding world writeable dirs")
    cmd =  "find / \'(\' -type d \')\'"
    cmd += " \'(\' -perm -o=w \')\' 2>/dev/null"
    dir_list_str = shell.raw_input(cmd)
    sep = dir_list_str[-2..-1] == "\r\n" ? "\r\n" : "\n"
    dir_list << dir_list_str.chomp("#{sep}").split("#{sep}").uniq
    t.kill
    print "\r"
    pp.clear_line
    pp.print_success("Found #{dir_list.flatten.length} world writeable dirs\n") if dir_list.flatten.length > 1
    pp.print_success("Found #{dir_list.flatten.length} world writeable dir\n") if dir_list.flatten.length == 1
    pp.print_error("Found #{dir_list.flatten.length} world writeable dirs\n") if dir_list.flatten.length == 0
    continue, warned = warn_user(pp, dir_list, warned)
    return dir_list, continue, warned
  end

  def run_script(shell, pp, rest_of_line = nil)
    #MANDATORY
    #necessary for all scripts
    arr_of_cmd_strings = ["find"]
    return unless which_commands(shell, pp, arr_of_cmd_strings) 
    #/MANDATORY

    #TODO errorchecking, nil response for groups
    user = shell.raw_input("whoami").chomp
    #haven't tested behavior for no groups
    #does a unix user need to have a group?
    all_groups =  shell.raw_input("groups").chomp
    pp.print_info("Searching for writeable directories\n")
    pp.print_info("This could take a while...\n")

    user_dir_list, continue, warned = find_user_writeable(shell, pp, user, false)
    groups_dir_list, continue, warned = find_groups_writeable(shell, pp, all_groups, warned) if continue
    world_dir_list, continue, warned = find_world_writeable(shell, pp, warned) if continue

    dir_list = []
    dir_list << user_dir_list unless user_dir_list.nil?
    dir_list << groups_dir_list unless groups_dir_list.nil?
    dir_list << world_dir_list unless world_dir_list.nil?

    dir_list = dir_list.flatten.uniq
    pp.print_success("Found #{dir_list.length} unique writeable directories\n") if dir_list.length > 1
    pp.print_success("Found #{dir_list.length} unique writeable directory\n") if dir_list.length == 1
    #hopefully never
    pp.print_error("Found #{dir_list.length} unique writeable directories\n") if dir_list.length == 0
  end
#FindWriteableDirs  
end

#find / '(' -type d ')' '(' '(' -user jeff -perm -u=w ')' -or '(' -group nobody -perm -g=w ')' -or '(' -perm -o=w ')' ')' -print 2>/dev/null