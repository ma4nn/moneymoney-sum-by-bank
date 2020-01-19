## Usage

For this AppleScript to work it is necessary to add a custom attribute `bankIdentifier` to each account in MoneyMoney
that you want to track. The sums are then grouped per this chosen bank identifier.

*Note: Basically a better way would be to group by account bic but not all accounts do have a bic (e.g. credit cards).* 

Then using the Automator script `test.app` you have a new menu item in MoneyMoney > Services > MoneyMoney - Sum by Bank.

After click on this menu item, Microsoft Excel will open and show all bank sums in a descending order.
