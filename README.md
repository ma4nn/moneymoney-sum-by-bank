# MoneyMoney Extension: Sum by Bank

This is a Pyton script for the great [MoneyMoney software](https://moneymoney-app.com/) to generate a list with all balances by bank account.  
This is useful e.g. to export the total values per bank to a summary Excel document or to monitor certain threshold values per bank.

## Installation

This script requires Python 3.10.

```
pip install -r requirements.txt
```

### Create service menu entry (optional)
On Mac if you (optionally) want to use this Python script within the services menu of the _MoneyMoney_ application, the best way is to use the [Mac Automator](https://support.apple.com/de-de/guide/automator/aut73234890a/mac): 
1. Create a new "Quick Action Workflow" in Automator 
2. Choose "No Input" in "MoneyMoney"
3. Add the action "Execute AppleScript" and paste this script into the text box and adapt the script path accordingly:
   ```applescript
   on run {input, parameters}
       tell application "Terminal"
           do script "python3 ~/path/to/script/moneymoney_sum_by_bank.py && read -s -n 1 key && exit 0"
       end tell
       
       return input
   end run
   ```
4. Save the workflow

Then you have a new menu item with the chosen name in _MoneyMoney > Services_.

## Usage

```shell
python3 moneymoney_sum_by_bank.py
```

**Note:** The MoneyMoney application has to be unlocked when executing the script otherwise an error will be thrown.

This Python script sums all account balances from MoneyMoney by BIC. If a BIC is not available (e.g. in case of an offline or a credit card account),
the script looks for a custom attribute `bankIdentifier` in the account settings and uses this as reference.  
If neither of this information is available on the account and it has a balance, the value is added to "other".

The result of the Python script can e.g. be used in Excel:  
![Excel file with sums by bank account](moneymoney-sum-by-bank.png "Excel file with sums by bank account")

For more information see also [my blog post](https://dev-investor.de/finanz-apps/money-money/maximum-pro-bank-extension/).

## License

[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)