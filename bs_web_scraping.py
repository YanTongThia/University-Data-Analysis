from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from collections import OrderedDict
from bs4 import BeautifulSoup
import csv
import time

# Set up the Selenium service and driver
s = Service(r"C:/Users/Yan Tong School/Downloads/chromedriver-win64/chromedriver.exe")
driver = webdriver.Chrome(service=s)

# Open the website
driver.get('https://www.timeshighereducation.com/world-university-rankings/2023/world-ranking#!/length/-1/sort_by/rank/sort_order/asc/cols/stats')

# Wait until the element with ID "datatable-1" is present in the DOM
wait = WebDriverWait(driver, 10)
element = wait.until(EC.presence_of_element_located((By.ID, "datatable-1")))

# Parse DOM into BeautifulSoup
soup = BeautifulSoup(driver.page_source, 'html.parser')

# Write Output into Text File
with open('output_stats.txt', 'w', encoding='utf-8') as file:
    file.write(soup.prettify())

# Write Output to CSV File
with open('scraped_data_stats.csv', 'w', newline='', encoding='utf-8-sig') as csvfile:

    csvwriter = csv.writer(csvfile, quoting=csv.QUOTE_NONNUMERIC)

     # Define the custom header for the CSV file
    custom_header = ["Rank", "UniversityName", "Country", "No.FTE_Students","No.Student_Per_Staff","InternationalStudents","F:M_Ratio","F_Ratio","M_Ratio"] 
    csvwriter.writerow(custom_header)

    # Iterate over each row in the BeautifulSoup object
    for row_idx, row in enumerate(soup.find_all("tr")):

        if row_idx == 0:  # Skip the first row (index 0)
            continue

        elements = row.find_all()
        # Extract and print the text content of each element
        data = [element.text.strip().encode('utf-8').decode('utf-8') for element in elements]
        # Create Ordered Dictionary from list extract and return unique List of Keys
        ul = list(OrderedDict.fromkeys(data).keys())
        # Remove Specific List Elements
        ul.pop(1)

        if "Explore" in ul:
            ul.remove("Explore")
        elif "Not accredited" in ul:
            ul.remove("Not accredited")

        last_element = ul[-1]

        if ' : ' in last_element:
            x, y = last_element.split(' : ')
            ul.append(x)
            ul.append(y)
        else:
            ul.append(None)  # If 'x : y' format is not present, append None for both numbers
            ul.append(None)

        ul[-3] = "'" + ul[-3]

        csvwriter.writerow(ul)
    
time.sleep(2)
driver.quit()

driver2 = webdriver.Chrome(service=s)
driver2.get('https://www.timeshighereducation.com/world-university-rankings/2023/world-ranking#!/length/-1/sort_by/rank/sort_order/asc/cols/scores')

wait2 = WebDriverWait(driver2, 10)
element2 = wait2.until(EC.presence_of_element_located((By.ID, "datatable-1")))

soup2 = BeautifulSoup(driver2.page_source, 'html.parser')

with open('output_scores.txt', 'w', encoding='utf-8') as file:
    file.write(soup.prettify())

with open('scraped_data_scores.csv', 'w', newline='', encoding='utf-8-sig') as csvfile:

    csvwriter = csv.writer(csvfile, quoting=csv.QUOTE_NONNUMERIC)

    custom_header = ["Rank", "UniversityName", "Country", "Overall","Teaching","Research","Citations","IndustryIncome","InternationalOutlook"] 
    csvwriter.writerow(custom_header)

    for row_idx, row in enumerate(soup2.find_all("tr")):

        if row_idx == 0: 
            continue

        elements = row.find_all()

        data = [element.text.strip().encode('utf-8').decode('utf-8') for element in elements]
        
        ul = list(OrderedDict.fromkeys(data).keys())
        ul.pop(1)

        if "Explore" in ul:
            ul.remove("Explore")
        elif "Not accredited" in ul:
            ul.remove("Not accredited")

        csvwriter.writerow(ul)

time.sleep(2)
driver2.quit()

