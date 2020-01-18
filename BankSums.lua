Exporter{version          = 1.00,
         format           = "Sum per Account",
         fileExtension    = "ryczznfvqkgdqnnu", -- unfortunately the AppleScript exporter can distinguish the export format only by file extension so we have to provide a unique one here (only lowercase allowed)
         reverseOrder     = false,
         description      = "Export transactions summed up per account."}

country = "DE"
customAttributeBankIdentifier = "bankIdentifier"

local function writeLine(line)
   assert(io.write(line, "\n"))
end

local function csvField (str)
  -- Helper function for quoting separator character and escaping double quotes.
  if str == nil then
    return ""
  elseif string.find(str, ";") then
    return '"' .. string.gsub(str, '"', '""') .. '"'
  else
    return str
  end
end

-- called once at the beginning of the export
function WriteHeader (account, startDate, endDate, transactionCount)
    -- initialize global array to store category sums
    -- bankSums = {}

    -- writeLine(os.date("Bank Code;Bank Name;Amount"))
end

-- called for every booking day
function WriteTransactions (account, transactions)
    -- bankCode = account.bankCode;
    -- if (bankSums[bankCode]) then
    --    bankSums[bankCode] = bankSums[bankCode] + account.balance
    -- else
    --    bankSums[bankCode] = account.balance
    -- end

    -- for _,transaction in ipairs(transactions) do
    --    bankCode = transaction.bankCode
    --    if bankCode ~= "" then
    --        if (bankSums[bankCode]) then
    --            bankSums[bankCode] = bankSums[bankCode] + transaction.amount
    --        else
    --            bankSums[bankCode] = transaction.amount
    --        end
    --    end
    -- end
end

function WriteTail (account)

    -- for bankCode, amount in pairs(bankSums) do
    --     writeLine(csvField(bankCode) .. ";" .. csvField(MM.localizeAmount(amount)) .. "\n")
    -- end

    -- Basically a better way would be to group by account.bic but not all accounts do have a bic (e.g. credit cards).

    if account.portfolio then
        return
    end

    bank = '(no identifier)';

    for key, value in pairs(account.attributes) do
        if key == customAttributeBankIdentifier then
            bank = value;
            break;
        end
    end

    writeLine(csvField(bank) .. ";" .. csvField(account.balance))
end

-- SIGNATURE: X