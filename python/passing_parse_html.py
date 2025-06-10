# Parsing the html files to extract PASSING data
# This version creates data frame with header row still being inserted
# Great for data cleaning practice

import pandas as pd
from bs4 import BeautifulSoup
import os
from io import StringIO

years = list(range(1976,2025))

dfs= []
for year in years:
    file_path = f'C:/Users/raul_/PycharmProjects/NFL_Webscrapping/profootballreference/stats/html_files/passing/{year}.html'

    if os.path.exists(file_path):
        with open(file_path, encoding='utf-8') as f:
            page = f.read()

        soup = BeautifulSoup(page, 'html.parser')

        soup.find('tr', class_='thead').decompose()

        pass_table = soup.find(id='passing')
        if pass_table is None:
                print(f'Table not found for passing year {year}')
        else:
            passing = pd.read_html(StringIO(str(pass_table)))[0]

            passing['Year'] = year

            dfs.append(passing)
    else:
        print(f'File not found: {file_path}')

# Combine all DataFrames
combined_df = pd.concat(dfs, ignore_index=True)

# Save combined DataFrame to CSV
save_path = f'C:/Users/raul_/PycharmProjects/NFL_Webscrapping/profootballreference/csv/'
combined_df.to_csv(f'{save_path}passing.csv', index=False)