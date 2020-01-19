on ExportAccounts()
	tell application "MoneyMoney"
		set accounts to export accounts
	end tell

	-- @todo check if there is any other way than to temporary safe the plist file
	set tmpDir to path to temporary items from user domain as text
	-- @todo remove fixed temporary path but unfortunately the temporary items from user domain variable is obviously too long for the property list file to work
	set tmpDir to "Macintosh HD:Users:cma:_temp:"
	set UUID to do shell script "uuidgen"
	set accountsPropertyListFile to (tmpDir & UUID & ".plist")
	set accountsPropertyListFilePosix to POSIX path of accountsPropertyListFile

	open for access file the accountsPropertyListFile with write permission
	write (accounts) to file the accountsPropertyListFile as «class utf8»
	close access file the accountsPropertyListFile

	log "Accounts file has been generated to " & accountsPropertyListFilePosix

	return accountsPropertyListFilePosix
end ExportAccounts

on SumBankBalances(accountsPropertyListFile)
	tell application "System Events"
		-- @todo remove fixed file
		tell property list file accountsPropertyListFile
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

	if resultFiles is {} then
		error "Temporary property list file " & accountsPropertyListFile & " could not be read or is empty."
	end if

	-- @todo make delimiter configurable
	set result to do shell script "LC_ALL=de_DE.UTF-8 awk 'BEGIN { FS = OFS = \";\" } { balance[$1] += $2; bank[$1] = $1; } END { for (i in bank) { printf \"%'\"'\"'.2f;%s\\n\", balance[i], bank[i]; } }' " & resultFiles

	-- @todo clean temporary file(s)

	return paragraphs of result
end SumBankBalances

on OpenExcelWithData(bankBalances)
	tell application "Microsoft Excel"
		activate
		make new workbook
		set x to 1

		set oldDelims to AppleScript's text item delimiters
		set AppleScript's text item delimiters to ";"
		repeat with singleLine in bankBalances
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
end OpenExcelWithData

set accountsPropertyListFile to ExportAccounts()
set bankBalances to SumBankBalances(accountsPropertyListFile)

OpenExcelWithData(bankBalances)
