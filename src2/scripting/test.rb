require_relative "corescript.rb"

class Test < CoreScript

  def initialize(pretty_print)
    keyword = 'test'
    description = 'basic script to test core scripts!'
    @options = Hash.new
    option_parser = OptionParser.new
    option_parser.banner = "Usage: test [options]"
    option_parser.on("-t", "--test", "Test flag"){@options[:test] = true}
    option_parser.on("-i", "--integer i", Integer, "Integer to echo"){|i| @options[:integer] = i}
    option_parser.on_tail("-h", "--help", "Show this message") do
      #nicely formatted help message
      puts option_parser
    end
    super(keyword, description, option_parser, pretty_print)
  end

  def run_script(shell, pp, rest_of_line = nil)
    #run_script receives the trailing line
    #if this argument is nil, there was nothing
    #but whitespace following the keyword
    #parse rest_of_line
    parse(rest_of_line.split) unless rest_of_line.nil?
    
    #example of a required argument
    puts "-t flag is required" if @options[:test].nil?
    raise OptionParser::MissingArgument if @options[:test].nil?

    #example of an optional argument
    puts "#{@options[:integer]}" unless @options[:integer].nil?

    puts "I am the test script, here is my description"
    puts self.inspect
    puts "Here is my help banner"
    puts @option_parser
  end
#Test  
end
#good link on implementation of option parser
#https://www.thoughtco.com/using-optionparser-2907754

