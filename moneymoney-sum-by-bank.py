import pandas as pd
import plistlib
import subprocess
import logging


def run_apple_script(script):
    command = ['osascript', '-e', script]
    with subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as pipe:
        result = pipe.communicate()
        if result[1]:
            raise Exception('Could not run Apple Script: %s' % result[1].decode().strip())

        return result


# @see https://moneymoney-app.com/applescript/
def fetch_moneymoney_accounts() -> {}:
    result = run_apple_script('tell application "MoneyMoney" to export accounts')

    # Parse XML property list.
    try:
        plist = plistlib.loads(result[0])
    except plistlib.InvalidFileException as exception:
        raise Exception('Could not parse XML property list. %s' % repr(exception))

    return plist


def moneymoney_sum_by_account() -> pd.DataFrame:
    balance_per_bank_and_currency = []
    for account in fetch_moneymoney_accounts():
        if account['portfolio'] is True or account['group'] is True:
            continue

        if not account['bankCode']:
            account['bankCode'] = account['attributes']['bankIdentifier'] if 'bankIdentifier' in account['attributes'] else 'other'
            logging.debug("Account %s has no bank code, using '%s'" % (account["name"], account['bankCode']))

        for balance in account['balance']:
            balance_per_bank_and_currency.append([account['bankCode'], balance[0], balance[1]])

    df = pd.DataFrame(balance_per_bank_and_currency, columns=['bank', 'balance', 'currency'])
    return df.groupby(['bank', 'currency']).agg({'balance': 'sum'})


#logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
df = moneymoney_sum_by_account()
print(df[df['balance'] > 0].sort_values(by='balance', ascending=False))
