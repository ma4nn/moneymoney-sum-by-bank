tell application "System Events"
	tell property list file "/Users/cma/_temp/test.plist"
		
		set resultFiles to {}
		
		repeat with i from 1 to number of property list items
			set bankCode to value of property list item "accountNumber" of property list item i
			
			if bankCode is not "" then
				tell application "MoneyMoney"
					try
						-- @todo last transaction sufficent?
						set resultFile to export transactions from account bankCode from date "Donnerstag, 1. Januar 1970 um 00:00:00" as "ryczznfvqkgdqnnu"
						set end of resultFiles to resultFile & " "
						log "Export for " & bankCode & " written to " & resultFile
					on error errStr number errorNumber
						log "ERROR: " & errStr & " (" & errorNumber & ")"
					end try
				end tell
			else
				log "Bank code missing for " & value of property list item "name" of property list item i & "!"
			end if
		end repeat
		
	end tell
end tell

-- @todo make delimiter configurable
set result to do shell script "LC_ALL=de_DE.UTF-8 awk 'BEGIN { FS = OFS = \";\" } { balance[$1] += $2; bank[$1] = $1; } END { for (i in bank) { printf \"%'\"'\"'.2f;%s\\n\", balance[i], bank[i]; } }' " & resultFiles
set singleLines to paragraphs of result

tell application "Microsoft Excel"
	activate
	make new workbook
	set x to 1
	set y to 1

	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ";"
	repeat with singleLine in singleLines
		set balance to text item 1 of singleLine
		set bank to text item 2 of singleLine

		set value of cell x of column 1 to balance
		set value of cell x of column 2 to bank
		set x to (x + 1)
	end repeat

	set AppleScript's text item delimiters to oldDelims

	set number format of range "$A1:$A100" to "#,##0.00 €"
	sort range "A1:B10" key1 range "A1" order1 sort descending
end tell
