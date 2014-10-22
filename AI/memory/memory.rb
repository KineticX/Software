require "pstore"
require 'pp'


# ------------------------
# BASE: find
# ---------------------

# ------------------------
# ACQUIRED: Init
# ---------------------
def acquired_init
end

# ------------------------
# ACQUIRED: Reset
# ---------------------
def acquired_reset

	# -- Remove datafile if it exists
	if File.exist?(File.dirname(__FILE__)+"/../knowledge_acquired/long/memory.db")
		# Remove
		File.delete(File.dirname(__FILE__)+"/../knowledge_acquired/long/memory.db")
	end

	# -- Initialize new datafile
	db = PStore.new(File.dirname(__FILE__) + "/../knowledge_acquired/long/memory.db")
	db.transaction do
		    db["information"] = {"name" => "Jonathan", "dob" => "11/26/1980" }
	end
end

# ------------------------
# ACQUIRED: Add
# ---------------------
def acquired_addMemory(sCaller, sTag, sData, sExperienceType)

	db = PStore.new(File.dirname(__FILE__) + "/../knowledge_acquired/short/memory.db")
	
	time1 = Time.new
	sTime = time1.inspect
	
	db.transaction do |s| 

		list = s.roots
		list.each do |item|
		
			if db[item]['DataKey'].include?(sData.split(':').first)
				puts "I already know the definition of " + sData.split(':').first
				db[item] = {"tag" => "#{sTag}", "DataKey" => "#{sData}", "experiencetype" => "#{sExperienceType}" }
				return
			end
		end
	end
	db.transaction do
		db["#{sCaller}.#{sTime}"] = {"tag" => "#{sTag}", "DataKey" => "#{sData}", "type" => "#{sExperienceType}" }
	end				

	STDOUT.flush
	return "I have learned: (#{sTag}, #{sData})"
	
end

# ------------------------
# AQUIRED: Remove
# ---------------------
def acquired_delMemory
end

# ------------------------
# AQUIRED: 
# ---------------------
def acquired_delMemory
end


# ------------------------
# AQUIRED: find     
# ---------------------
def acquired_fndMemory(sMemory)
	db = PStore.new(File.dirname(__FILE__) + "/../knowledge_acquired/short/memory.db")

	result = nil
	db.transaction do |s| 

		list = s.roots
		list.each do |item|
			if db[item]['DataKey'].split(':').first.include?(sMemory)
				puts "I found " + sMemory + " it's definition: \n" + db[item]['DataKey'].split(':').last
			end
		end

	end
	return "hello"
	
end



