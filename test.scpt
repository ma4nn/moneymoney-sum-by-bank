
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
					on error errStr number errorNumber
						log "ERROR: " & errStr & " (" & errorNumber & ")"
					end try
				end tell
				log "Export for " & bankCode & " written to " & resultFile
			else
				log "Bank code missing for " & value of property list item "name" of property list item i & "!"
			end if
		end repeat

		return do shell script "awk 'BEGIN { FS = OFS = \";\" } { y[$1] += $2; $2 = y[$1]; x[$1] = $0; } END { for (i in x) { print x[i]; } }' " & resultFiles

	end tell
end tell