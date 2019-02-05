require_relative "corescript.rb"

Class Test < CoreScript
  def create_regex(flags)
    #TODO complete this function
    return /.*/
  end

  def initialize
    keyword = 'test'
    description = 'basic script to test core scripts!'
    flags.Hash.new{|hash, key| hash[key] = Hash.new}
    flags['-h'] = {
      :required => false 
      :description => "print help message"
    }
    regex = create_regex(flags)
    help_message = 'this is just a test script, sorry!'

    command = 'echo "loaded and working test script!"'
    super(keyword, commands, description, regex, help_message)

  end
#Test  
end