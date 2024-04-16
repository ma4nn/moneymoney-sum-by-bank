#!/usr/bin/env python3
"""
    Python MoneyMoney API

    @see https://moneymoney-app.com/applescript/
"""

import plistlib
import subprocess
from typing import TypedDict


class Account(TypedDict):
    name: str
    bankCode: str
    balance: list[list[float | str]]
    portfolio: bool
    group: bool
    attributes: dict[str, str]


def __run_apple_script(script: str) -> bytes:
    command = ['osascript', '-e', script]
    with subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as pipe:
        result = pipe.communicate()
        if result[1]:
            raise RuntimeError(f'Could not run Apple Script "{script}": {result[1].decode().strip()}')

        return result[0]


def fetch_moneymoney_accounts() -> list[Account]:
    result = __run_apple_script('tell application "MoneyMoney" to export accounts')

    # Parse XML property list.
    try:
        plist = plistlib.loads(result)
    except plistlib.InvalidFileException as exception:
        raise ValueError('Could not parse XML property list') from exception

    return plist
