class CoreScript

  attr_reader :keyword, :command, :description, :regex,
                                          :help_message
  
  def initialize(keyword, description, regex, 
                                            help_message)
    #keyword to invoke script
    @keyword = keyword
    #commands to run
    @command = "\n"
    #description of core script
    @description = description
    #regex to verify command has correct input
    @regex = regex
    #message to display on incorrect input
    #along with arg count/flags descriptions
    @help_message = help_message
  end

  def inspect
    "Command: #{@command}, Description #{@description}"
  end

#  def run_script(options = "")
#    raise "No run_script method defined" 
#  end
#core script
end