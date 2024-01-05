#!/usr/bin/env python3
"""
  Python script for the great MoneyMoney app to generate a list with total balance by bank account.
"""

import logging
import pandas as pd
from moneymoney_api import fetch_moneymoney_accounts, Account


def sum_by_account(accounts: list[Account]) -> pd.DataFrame:
    balance_per_bank_and_currency = []
    for account in accounts:
        if account['portfolio'] is True or account['group'] is True:
            continue

        if not account['bankCode']:
            account['bankCode'] = account['attributes']['bankIdentifier'] if 'bankIdentifier' in account['attributes'] else 'other'
            logging.debug("Account %s has no bank code, using '%s'", account["name"], account['bankCode'])

        for balance in account['balance']:
            balance_per_bank_and_currency.append([account['bankCode'], balance[0], balance[1]])

    df_balance_per_bank_and_currency = pd.DataFrame(balance_per_bank_and_currency, columns=['bank', 'balance', 'currency'])

    return df_balance_per_bank_and_currency.groupby(['bank', 'currency']).agg({'balance': 'sum'})


if __name__ == "__main__":
    # logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
    df = sum_by_account(fetch_moneymoney_accounts())
    print(df[df['balance'] > 0].sort_values(by='balance', ascending=False))
