-- combine-functions.applescript

-- Combines the XML files into a single FileMaker-object-as-XML block. 

property functionFolderName : "functions"

on run
	
	set functionFolderPath to fileParentFromPath({filePath:(path to me) as string, pathDelim:":"}) & functionFolderName & ":"
	
	tell application "Finder"
		
		repeat with oneFile in contents of (alias functionFolderPath)
			
			log oneFile
			
		end repeat
		
	end tell
	
	
	
end run





on fileParentFromPath(prefs)
	-- version 1.2, Daniel A. Shockley
	
	try
		set filePath to filePath of prefs
		set pathDelim to pathDelim of prefs
		
		set filePath to filePath as string
		if filePath is "" then
			error "Cannot find a parent folder for a path that is blank." number -1027
		end if
		
		if last character of filePath is pathDelim then
			-- if it ends with pathDelim (a folder), leave that off for the code below
			set filePath to (text 1 through -2 of filePath) as string
		end if
		
		set {od, AppleScript's text item delimiters} to {AppleScript's text item delimiters, pathDelim}
		if (count of text items of filePath) is 1 then
			-- the item in question is a disk, so CANNOT return a parent folder
			set AppleScript's text item delimiters to od
			error "Cannot find a parent folder of a DISK: " & filePath & "." number -1027
		else
			set enclosingFolder to (text items 1 through -2 of filePath as string)
		end if
		
		set AppleScript's text item delimiters to od
		return enclosingFolder & pathDelim
		
	on error errMsg number errNum
		error "fileParentFromPath FAILED: " & errMsg number errNum
		
	end try
	
	
end fileParentFromPath









on getTextBetween(prefs)
	-- version 1.7.1
	
	set defaultPrefs to {sourceTEXT:null, beforeText:null, afterText:null, textItemNum:2, includeMarkers:false}
	
	if (class of prefs is not list) and ((class of prefs) as string is not "record") then
		error "getTextBetween FAILED: parameter should be a record or list. If it is multiple items, just make it into a list to upgrade to this handler." number 1024
	end if
	if class of prefs is list then
		if (count of prefs) is 4 then
			set textItemNum of defaultPrefs to item 4 of prefs
		end if
		set prefs to {sourceTEXT:item 1 of prefs, beforeText:item 2 of prefs, afterText:item 3 of prefs}
	end if
	
	
	set prefs to prefs & defaultPrefs -- add on default preferences, if needed
	set sourceTEXT to sourceTEXT of prefs
	set beforeText to beforeText of prefs
	set afterText to afterText of prefs
	set textItemNum to textItemNum of prefs
	set includeMarkers to includeMarkers of prefs
	
	
	try
		set {oldDelims, AppleScript's text item delimiters} to {AppleScript's text item delimiters, beforeText}
		
		-- there may be multiple instances of beforeTEXT, so get everything after the first instance
		set prefixRemoved to text items textItemNum thru -1 of sourceTEXT
		set prefixRemoved to prefixRemoved as string
		
		-- get everything up to the afterTEXT
		set AppleScript's text item delimiters to afterText
		set the finalResult to text item 1 of prefixRemoved
		
		-- reset item delim
		set AppleScript's text item delimiters to oldDelims
		
		if includeMarkers then set finalResult to beforeText & finalResult & afterText
	on error errMsg number errNum
		set AppleScript's text item delimiters to oldDelims
		set the finalResult to "" -- return nothing if the surrounding text is not found
	end try
	
	return finalResult
end getTextBetween

