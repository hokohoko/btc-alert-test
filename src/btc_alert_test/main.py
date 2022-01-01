from time import sleep

import ccxt

ex = ccxt.binance()


def main():
    while True:
        ticker = ex.fetch_ticker(symbol="BTC/USDT")
        info = dict(time=ticker["datetime"], price=ticker["average"])
        print(info)
        sleep(3)


if __name__ == "__main__":
    main()