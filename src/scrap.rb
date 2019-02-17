  def run_script(shell, pp, rest_of_line = nil)
    #TODO errorchecking, nil response for groups
    user = shell.raw_input("whoami").chomp
    all_groups =  shell.raw_input("groups").chomp

    pp.print_info("Searching for writeable directories\n")
    pp.print_info("This could take a while...\n")
    t = pp.print_time_thread("Finding dirs writeable by User: #{user}\n")
    

  end