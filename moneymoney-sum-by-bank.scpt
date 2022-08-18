------------------------
-- CONFIGURATION

global exportFileName, startRowIndex, startColumnIndex, isSortDescending, isCloseExcel, cellThresholdValue, cellThresholdColor

-- The name of the resulting Excel file. You can either use an existing file or leave it to missing value to create a new one.
set exportFileName to missing value

-- The index of the cell row/column to start the table.
set startRowIndex to 1
set startColumnIndex to 1

-- Whether to sort the resulting sums in a descending order or not.
set isSortDescending to true

-- Whether to close Excel after the export.
set isCloseExcel to false

-- Threshold value above that the cell is colored
set cellThresholdValue to 100000
set cellThresholdColor to {255, 244, 233}
------------------------

global tmpDir
-- Note: we do not use "path to temporary items from user domain" because - despite the call - this is not in the user space!
set tmpDir to (path to library folder from user domain as text) & "Caches:"

-- Export all accounts from MoneyMoney application into temporary folder.
-- The temporary folder is necessary because the plist result of the "export accounts" command cannot be processed easily
-- with AppleScript otherwise.
on ExportAccounts()
	tell application "MoneyMoney"
		set accounts to export accounts
	end tell

	-- @todo check if there is any other way than to temporary safe the plist file
	set UUID to do shell script "uuidgen"
	set accountsPropertyListFile to (tmpDir & UUID & ".plist")
	set accountsPropertyListFilePosix to POSIX path of accountsPropertyListFile

	open for access file the accountsPropertyListFile with write permission
	write (accounts) to file the accountsPropertyListFile as «class utf8»
	close access file the accountsPropertyListFile

	log "Accounts file has been generated to " & accountsPropertyListFilePosix

	return accountsPropertyListFilePosix
end ExportAccounts

on DeleteFile(fileName)
	log "INFO: removing temporary file " & fileName

	-- this statement returns an error if parameter fileName is not a real file
	-- this way we prohibit removing a whole directory
	do shell script "test -f " & fileName as POSIX file

	tell application "System Events" to delete alias fileName
end DeleteFile

-- Increase the balance value of the given bank in the balancePerBankList list
on IncreaseBankBalance(bankIdentifier, balance, balancePerBankList)
	log "INFO: Increase bank balance of " & bankIdentifier & " by " & balance

	repeat with a from 1 to the count of balancePerBankList
		if bankIdentifier of item a of balancePerBankList is bankIdentifier then
			set newBalance to (balance of item a of balancePerBankList) + balance
			log "DEBUG: Found existing balance. Set new balance to " & newBalance
			set item a of balancePerBankList to {bankIdentifier:bankIdentifier, balance:newBalance}

			return balancePerBankList
		end if
	end repeat

	set the end of balancePerBankList to {bankIdentifier:bankIdentifier, balance:balance}
	return balancePerBankList
end IncreaseBankBalance

-- Sum up all bank balances in the given plist file from MoneyMoney
on SumBankBalancesFromPlist(accountsPropertyListFile)
	-- balancePerBankList is an object like {{bankIdentifier: "DKB", balance: 200, bankIdentifier: "Commerzbank", balance: 99, ..}
	set balancePerBankList to {}

	tell application "System Events"
		tell property list file accountsPropertyListFile
			repeat with i from 1 to number of property list items
				set bankIdentifier to ""
				set accountName to ""

				try
					set accountName to value of property list item "name" of property list item i
					set bankIdentifier to value of property list item "bankIdentifier" of property list item "attributes" of property list item i
					set balances to value of property list item "balance" of property list item i
					repeat with balance in balances
						-- @todo make addition work also for different currencies, at the moment we assume all is the same currency
						my IncreaseBankBalance(bankIdentifier, get first item of balance, balancePerBankList)
					end repeat
				on error errStr number errorNumber
					log "WARNING: " & errStr & ". Probably MoneyMoney Attribute 'bankIdentifier' not set for account " & accountName & ". Skipping.."
				end try
			end repeat
		end tell
	end tell

	if balancePerBankList is {} then
		error "Temporary property list file " & accountsPropertyListFile & " could not be read or no MoneyMoney accounts with attribute 'bankIdentifier' exists."
	end if

	return balancePerBankList
end SumBankBalancesFromPlist

-- Open Microsoft Excel application, insert bank sums and format and sort accordingly
on OpenExcelWithData(bankBalances)
	tell application "Microsoft Excel"
		activate
		if (exportFileName is missing value) then
			make new workbook
		else
			open exportFileName
		end if
		--
		set x to startRowIndex

		repeat with balanceData in bankBalances
			set balance to balance of balanceData
			set bank to bankIdentifier of balanceData

			set value of cell x of column startColumnIndex to balance
			set value of cell x of column (startColumnIndex + 1) to bank

			if (balance > cellThresholdValue) then
				set color of interior object of cell x of column startColumnIndex to cellThresholdColor
			end if

			set x to (x + 1)
		end repeat

		set number format of column startColumnIndex to "#,##0.00 €"

		if (isSortDescending is true) then
			set sortingRange to "" & startRowIndex & ":" & x
			sort range sortingRange key1 cell 1 of column startColumnIndex order1 sort descending
		end if

		if (exportFileName is not missing value) then
			save yes
		end if

		if (isCloseExcel is true) then
			close active workbook
		end if
	end tell
end OpenExcelWithData

set accountsPropertyListFile to ExportAccounts()
set bankBalances to SumBankBalancesFromPlist(accountsPropertyListFile)

OpenExcelWithData(bankBalances)

DeleteFile(accountsPropertyListFile)
