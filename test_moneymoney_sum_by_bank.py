#!/usr/bin/env python3
"""
    Unit Tests
"""

import unittest
import pandas as pd
from pandas.testing import assert_frame_equal
from moneymoney_api import Account
from moneymoney_sum_by_bank import sum_by_account


class TestSumByBank(unittest.TestCase):

    def test_empty(self):
        df = sum_by_account([])

        assert df.empty is True

    def test_single_account(self):
        accounts: list[Account] = [
            Account(name='Test Bank A', balance=[[1000.00, 'EUR']], portfolio=False, group=False, bankCode='TES1')
        ]

        df_expected = pd.DataFrame([{'bank': 'TES1', 'currency': 'EUR', 'balance': 1000.00}]).set_index(['bank', 'currency'])
        df = sum_by_account(accounts)

        assert_frame_equal(df_expected, df, check_exact=True)

    def test_single_account_no_bank_code(self):
        accounts: list[Account] = [
            Account(name='Test Bank A', balance=[[1000.00, 'EUR']], portfolio=False, group=False, bankCode='', attributes={'bankIdentifier': 'TES1'})
        ]

        df_expected = pd.DataFrame([{'bank': 'TES1', 'currency': 'EUR', 'balance': 1000.00}]).set_index(['bank', 'currency'])
        df = sum_by_account(accounts)

        assert_frame_equal(df_expected, df, check_exact=True)

    def test_multi_accounts_same_bank(self):
        accounts: list[Account] = [
            Account(name='Test Bank A', balance=[[1000.00, 'EUR']], portfolio=False, group=False, bankCode='TES1'),
            Account(name='Test Bank A', balance=[[490.18, 'EUR']], portfolio=False, group=False, bankCode='TES1')
        ]

        df_expected = pd.DataFrame([{'bank': 'TES1', 'currency': 'EUR', 'balance': 1490.18}]).set_index(['bank', 'currency'])
        df = sum_by_account(accounts)

        assert_frame_equal(df_expected, df, check_exact=True)

    def test_multi_accounts(self):
        accounts: list[Account] = [
            Account(name='Test Bank A', balance=[[1000.00, 'EUR']], portfolio=False, group=False, bankCode='TES1'),
            Account(name='Test Bank A', balance=[[490.18, 'EUR']], portfolio=False, group=False, bankCode='TES1IGNORED'),
            Account(name='Test Bank B', balance=[[0.99, 'EUR']], portfolio=False, group=False, bankCode='TES2'),
            Account(name='Test Bank C', balance=[[0, 'EUR']], portfolio=False, group=False, bankCode='TES3'),
            Account(name='Test Bank B', balance=[[0.9988, 'EUR']], portfolio=False, group=False, bankCode='TES2')
        ]

        df_expected = pd.DataFrame([{'bank': 'TES1', 'currency': 'EUR', 'balance': 1490.18}, {'bank': 'TES2', 'currency': 'EUR', 'balance': 1.9888}, {'bank': 'TES3', 'currency': 'EUR', 'balance': 0}]).set_index(['bank', 'currency'])
        df = sum_by_account(accounts)

        assert_frame_equal(df_expected, df, check_exact=True)
