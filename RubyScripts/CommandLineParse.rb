# -- Add load path for require / include modules
$LOAD_PATH.unshift File.dirname(__FILE__)


# - Required modules / includes (Adds functionality)
require 'rubygems'
require 'json'
require 'optparse'
require 'pty'
require 'pp'
require 'socket'

# -- Current Framework Version
@FrameWorkVersion = 'X.X.X.X'


# -- Variable definitions


# -------------------------------------------------
# FUNC: sys_settingsParse
# DESC: Converts command line arguments to 
# A set of Settings available to all.
# -------------------------------------------------
def sys_settingsParse (sDefinitionsfile="")

		debug "-------------------------------------------------"
		debug "BEGIN COMMAND LINE PARSER"
		debug "-------------------------------------------------"
		hEnvironmentSettings = Hash.new
		hEnvironmentSettings = fGetEnvironmentVariables(sDefinitionsfile)

		debug "Argument config file (sDefinitions): #{sDefinitionsfile}"
		debug "Environment based settings (hEnvironmentSettings): #{hEnvironmentSettings}"

		# -- Read config as jSON
	   result = JSON.parse( IO.read(sDefinitionsfile) )
	
		# -- Method level variable definitions
		sOptVariableName = ''
		sOptLongFormat 	= ''
		sOptShortFormat  = ''
		sOptDescription  = ''
		sOptRequired = false
		sOptValue = false
		iCounter = 0
		bFailedRequiredParmsFlag = false
		bHasMetSubArgumentRequirement = false
		opts = OptionParser.new

		# -- define our final settings hash
		hSettings = Hash.new
		
		# -- get a list of valid options for the config convert to hash
		debug "Parsing JSON file for command line argument definitions"
		result['OPTION'].each do |option|
		   option.each do |key,value|
				case key
					when "variablename"
						debug "hSettings Key: #{value}"
						sOptVariableName = value
						hSettings[sOptVariableName] = false
					when "longformat"
						debug "longformat: #{value}"
						sOptLongFormat = value
					when "shortformat"
						debug "shortformat: #{value}"
						sOptShortFormat = value
					when "description"
						debug "description: #{value}"
						sOptDescription = value
					when "required"
						debug "required: " + value.to_s
						sOptRequired = value
					when "value"
						debug "value: " + "#{value}"
						sOptValue = value
				end
				iCounter+= 1
				
				# -- Make sure we have ALL required details on our new argument
				if iCounter == 6
								
						# -- Create options with proper formatting.
						if sOptValue == true && !sOptShortFormat.empty?
							opts.on("#{sOptShortFormat} [VALUE]", "#{sOptLongFormat} [VALUE]", "#{sOptDescription}") { }
						end
						if sOptValue == false && !sOptShortFormat.empty?
							opts.on("#{sOptShortFormat}", "#{sOptLongFormat}", "#{sOptDescription}") { }  
						end
						if sOptShortFormat.empty? && sOptValue == false
							opts.on("#{sOptLongFormat}", "#{sOptDescription}") { }  
						end
						if sOptShortFormat.empty? && sOptValue == true
							opts.on("#{sOptLongFormat} [VALUE]", "#{sOptDescription}") { }  
							
						end
						
						# -- Handle Required Arguments 
						if sOptRequired == true
						
							# -- Search ARGV for matching shortoptformat argument (-x)
							debug "Attempting to satisfy required flag (IF required to do so) for #{sOptVariableName} "
							
							bThisArgSatisfiesRequiredOption = false
							opts.default_argv.each_with_index do |z,index|
								if ((z == sOptShortFormat) || (sOptLongFormat == z)) 
									bThisArgSatisfiesRequiredOption = true 
								end
							end
							
							# -- Set Failed required argument flag IF required and not present in ARGV
							if bThisArgSatisfiesRequiredOption == false
								WARN "User failed to specify argument: #{sOptShortFormat} || #{sOptLongFormat}" 
								bFailedRequiredParmsFlag = true
							end
						
						end
					
					
					
						# -- Determine if the subarg requirments are met for this variable (if no sub args bHasMet... is false)
						debug "Find sub arguments and set those as values in hSettings #{bHasMetSubArgumentRequirement}"
						opts.default_argv.each_with_index do |z,index|
							
								iArgLoc = index + 1
								if (z == sOptShortFormat or z == sOptLongFormat) 
										sUserProvidedValue = opts.default_argv[iArgLoc].to_s
										debug "Matched main arg in search for value #{sOptVariableName} "
										hSettings[sOptVariableName] = true

										# -- This is a compound if which basically tests if we have a required value for a option && a value is required
										if ((!sUserProvidedValue.to_s.start_with?('-')) && (sOptValue == true and sUserProvidedValue.length > 0)) then												hSettings[sOptVariableName] = opts.default_argv[iArgLoc] 
												bHasMetSubArgumentRequirement = true
										end
								end

						end
				   		opts.default_argv.each do |z|
				
								# -- Determine if requiredsubargvalue should kill the app..
								debug "Determine if a required sub arg value missing should kill the app"
								debug "Z: #{z}" 
								debug "sOptShortFormat: #{sOptShortFormat}"
								debug "sOptShortFormat: #{sOptLongFormat}"
								debug "sOptValue: #{sOptValue}"
								debug "bHasMetSubArgumentRequirement: #{bHasMetSubArgumentRequirement}"								
								if z == sOptShortFormat or z == sOptLongFormat 
									debug "found matching option on command line"
									if bHasMetSubArgumentRequirement == false and sOptValue == true
										debug "found a arg passed in with no sub arg specified"
										FATL "Failed to get required sub-argument (#{sOptLongFormat} [VALUE] OR #{sOptShortFormat} [VALUE])" 
									end
								end
						
						end
					
						# -- Reset the loop flags
						bHasMetSubArgumentRequirement = false
						iCounter = 0
					end
			end	
		end
		opts.on('--h', "--help", "Displays usage information & help document")    { puts opts; exit 0 }
		opts.parse(ARGV)
		
		
		# -- If we failed to get all required args then we die and display help
		if bFailedRequiredParmsFlag == true
			puts opts
			exit 0
		end

		debug "FINAL ENV SETTINGS #{hEnvironmentSettings}"
		# -- Merge command line options with environment options (ENV taking precidence)
		hEnvironmentSettings.keys.sort.each do |key|
		  			
				hSettings[key] = hEnvironmentSettings[key]
				if hEnvironmentSettings[key] == false or hEnvironmentSettings[key] == "false" then 
					hSettings[key] = false  
				end
				if hEnvironmentSettings[key] == true or hEnvironmentSettings[key] == "true" then 
					hSettings[key] = true 
				end
		
		end
		#pp hSettings
		debug "Final hSettings (HASH) value #{hSettings}"
		debug "-------------------------------------------------"
		debug "END COMMAND LINE PARSE"
		debug "-------------------------------------------------"
		
		return hSettings
end

# -------------------------------------------------
# FUNC: fGetEnvironmentVariables
# DESC: Converts ENV Variables into a HASH
# -------------------------------------------------
def fGetEnvironmentVariables (sDefinitionsfile) 
     	# -- figure out config file
		# -- read config as jSON
	   result = JSON.parse( IO.read(sDefinitionsfile) )
		sOptVariableName = ''
		sOptLongFormat 	= ''
		sOptShortFormat  = ''
		sOptDescription  = ''
		sOptRequired = false
		sOptValue = false
		iCounter = 0
		bHasMetSubArgumentRequirement = false
		opts = OptionParser.new
		
		hSettings = Hash.new
		
			# -- get a list of valid options for the config convert to hash
			result['OPTION'].each do |option|
			   option.each do |key,value|
					case key
						when "variablename"
							debug "Variable: #{value}"
							sOptVariableName = value
						when "longformat"
							debug "longformat: #{value}"
							sOptLongFormat = value
						when "shortformat"
							debug "shortformat: #{value}"
							sOptShortFormat = value
						when "description"
							debug "description: #{value}"
							sOptDescription = value
						when "required"
						   "required: " + value.to_s
							sOptRequired = value
						when "value"
							debug "SET value: " + "#{value}"
							sOptValue = value if value.to_s.length > 1
							sOptValue = false if value.to_s.length < 2
						end
					iCounter+= 1
					
					# -- Make sure we have ALL required details on our Environment Variable
					if iCounter == 6
						# -- If set add to hash
						unless ENV[sOptVariableName].nil?
								debug "setting #{sOptVariableName} = #{ENV['sOptVariableName']}"
								
								if ENV[sOptVariableName] == false or ENV[sOptVariableName] == "false" then 
									debug "Setting ENV: #{sOptVariableName} to false"
									hSettings[sOptVariableName] = false  
								end
								if ENV[sOptVariableName] == true or ENV[sOptVariableName] == "true" then 
									debug "Setting ENV: #{sOptVariableName} to true"
									hSettings[sOptVariableName] = true 
								end
								unless hSettings[sOptVariableName] == true then 
									unless hSettings[sOptVariableName] == false then
										debug "Setting ENV:#{sOptVariableName} = #{ENV[sOptVariableName]}"
										hSettings[sOptVariableName] = ENV[sOptVariableName]
									end
								end
								
						end
						iCounter = 0 
					end		
			
				end

			end
			#pp hSettings
			return hSettings


end

