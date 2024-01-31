# Jadwiga Swierczynska
# 20.11.2023

import aiohttp
import asyncio
import private


# fetching currency rate from National Bank of Poland website
async def NBP_get_currency_rate(session, currency):
    async with session.get(f'http://api.nbp.pl/api/exchangerates/rates/a/{currency}/') as response:
        html = await response.json()
        print("NBP\n-------")
        print("waluta: ", html['currency'])
        print("kod waluty: ", html['code'])
        print("data: ", html['rates'][0]['effectiveDate'])
        print("średni kurs: ", html['rates'][0]['mid'])
        print("\n")


# fetching random aphorism 
async def get_aphorism(session):
    async with session.get("https://fortune-cookie4.p.rapidapi.com/", \
                               headers = {"X-RapidAPI-Key" : private.API_KEY, "X-RapidAPI-Host": "fortune-cookie4.p.rapidapi.com"}) as response:
        html = await response.json()
        print("Aforyzm\n-------")
        print(html['data']['message'])
        print("\n")

async def main():
    async with aiohttp.ClientSession() as session:
        await asyncio.gather(NBP_get_currency_rate(session, 'eur'), get_aphorism(session))

if __name__ == "__main__":
    asyncio.run(main())