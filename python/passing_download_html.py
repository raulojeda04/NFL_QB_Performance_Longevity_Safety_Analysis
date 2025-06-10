# Downloading html files for PASSING stats for years 1976-2024

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
import time
import requests
from tenacity import retry, stop_after_attempt, wait_fixed

# Initialize the Chrome WebDriver
service = Service("C:/Users/raul_/Downloads/chromedriver-win64/chromedriver-win64/chromedriver.exe")
driver = webdriver.Chrome(service=service)

# Headers for the requests
my_headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
}

# List of years we'll be extracting from
years = list(range(1976, 2025))


# Implement retry logic if get connection error
@retry(stop=stop_after_attempt(2), wait=wait_fixed(10))
def fetch_data(url, headers):
    return requests.get(url, headers=headers)


for year in years:
    url = f'https://www.pro-football-reference.com/years/{year}/passing.htm'

    # Request data with retry logic
    data = fetch_data(url, my_headers)

    # Use Selenium to fetch the page
    driver.get(url)
    driver.execute_script('window.scrollTo(1, 10000)')
    time.sleep(2)

    # Get page source
    html = driver.page_source

    # Print message to keep track of script progress
    if html:
        print(f'Downloaded page source for year: {year}')

    # Establish directory to save files
    directory = f'C:/Users/raul_/PycharmProjects/NFL_Webscrapping/profootballreference/stats/html_files/passing/'

    # Save html files to directory
    with open(f'{directory}{year}.html', 'w+', encoding='utf-8') as f:
        f.write(html)

# Remember to quit webdriver (outside of loop)
driver.quit()





