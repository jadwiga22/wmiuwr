# Jadwiga Swierczynska
# 28.11.2023

import calendar
import requests
from statistics import mean
import matplotlib.pyplot as plt

YEARS = [2021,2022]
MONTHS = list(range(1,13))
# months codes in GUS website
PERIODS_GUS = list(range(247,247+12)) 

# fetching currency data and calculating average rate
def fetch_month_NBP(month, year, currency):
    last = calendar.monthrange(year,month)[1]
    r = requests.get(f"http://api.nbp.pl/api/exchangerates/rates/a/{currency}/{year}-{month:02d}-01/{year}-{month:02d}-{last:02d}")
    return mean([d["mid"] for d in r.json()["rates"]])

# fetching all data in 2021 and 2022 for specified currency    
def get_NBP_data(currency):
    res = {"name" : f"Średni kurs {currency.upper()} (w zł)"}
    for y in YEARS:
        res[y] = {}
        for m in MONTHS:
            res[y][m] = fetch_month_NBP(m,y,currency)
 
    return res

# linearly extrapolating value 
def next_val_linear(x1, x2):
    return x2 + (x2 - x1)

# extrapolating values for each month in 2023
def extrapolate(data):
    res = {}
    for m in MONTHS:
        res[m] = next_val_linear(data[YEARS[0]][m], data[YEARS[1]][m])
    return res

# generating plots for 2021 - 2023
def gen_plots(data1, data2):
    # extrapolating data for 2023
    data1[2023] = extrapolate(data1)
    data2[2023] = extrapolate(data2)

    fig, (ax1, ax2, ax3) = plt.subplots(3,1)
    fig.set_size_inches(9,9)

    ax = {2021 : ax1, 2022 : ax2, 2023 : ax3}
    xs = [calendar.month_abbr[m] for m in MONTHS]

    for y in YEARS + [2023]:    
        axi = ax[y]
        title = f"Rok {y}"
        if y == 2023:
            title += " - przewidywania"
        axi.set_title(title)
            
        ys1 = list(data1[y].values())
        ys2 = list(data2[y].values())
        axi.plot(xs, ys1, marker='x')
        axi.plot(xs, ys2, marker='o')
        axi.legend([data1["name"], data2["name"]], loc='center left', bbox_to_anchor=(1, 0.5))
    
    plt.tight_layout()    
    plt.show()

def get_GUS_data():
    res = {"name" : "Inflacja (w %)"}
    params = {
        "id-zmienna" : "305", 
        "id-przekroj" : "736",
        "ile-na-stronie" : 20,
        "numer-strony" : 0,
        "lang" : "pl"
    }
    for y in YEARS:
        res[y] = {}
        for m, month_num in zip(PERIODS_GUS, MONTHS):
            params["id-rok"] = y
            params["id-okres"] = m
            r = requests.get("https://api-dbw.stat.gov.pl/api/1.1.0/variable/variable-data-section", params=params)

            # 15 - mierzenie inflacji wzgledem analogicznego okresu wczesniejszego roku,
            # dla ogolu gospodarstw domowych, 
            # przez ogol towarow i uslug
            cur = r.json()["data"][15]
            res[y][month_num] = cur["wartosc"] - 100

    return res


def main():
    data_NBP_gbp = get_NBP_data("gbp")
    data_GUS_infl = get_GUS_data()
    gen_plots(data_NBP_gbp,data_GUS_infl)
    

if __name__ == "__main__":
    main()
