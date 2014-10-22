$LOAD_PATH.unshift File.dirname(__FILE__)+"/../memory/"
require "memory.rb"

# ------------------------------
# Main Entry Point
# ---------------------------
def main()

	aMethods = self.public_methods(false)
	aMethods.each do |sInputMethod|
		 method(sInputMethod).call() if sInputMethod.include?("input_") 
	end
end


# ------------------------------
# Console input
# ---------------------------
def self.input_Console
	puts "Initializing Artificial Intelligence console input engine..."
	Thread.new do
		
		loop do
                        print "Console Input:>"
                        STDOUT.flush
	
			s = gets.chomp
			case s
				when 'exit'
					puts "\nGood Bye"
					exit
				when /learn/
				
					sTag = s.split(' ')[1].gsub('learn','').strip
					sData = s.split(sTag)[-1].strip
					load "memory.rb"
					answer = acquired_addMemory("learned", sTag, sData, "neutral")
					puts "\n"+answer
					
					STDOUT.flush

				when /recall/
					
					load "memory.rb"
					sMemory = s.split(" ").last.strip
					puts "I am trying to recall " + s.split(" ").last.strip		
					answer = acquired_fndMemory(sMemory)

				when /execute/
					action = s.split(" ").last.strip
					action_module = action.split(":").first.strip
					action = action.split(":").last.strip

					puts "I am executing #{action} for #{action_module}"

				else
					puts "\ngrumble grumble.."
			end
                        
	  	  end
	end
end



# -- Call our main thread
main()
