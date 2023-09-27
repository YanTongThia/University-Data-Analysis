# University-Data-Analytics

Thoroughly examine the primary factors that have affected university rankings and evaluate how they have contributed to Nanyang Technological University's (NTU) recent decline in rankings. This analysis leverages publicly accessible web data extracted from [[URL](https://www.timeshighereducation.com/world-university-rankings/2023/world-ranking)] with the aim of offering actionable insights to assist NTU in strategically improving its ranking position. The technological tools employed for this endeavor encompass Python for web scraping and R for data analysis.

## Table of Contents

- [Project Overview](#project-overview)
- [Web Scraping](#web-scraping)
- [Findings](#findings)
- [Acknowledgments](#acknowledgments)

## Project Overview

The objective of this data analytics project is to comprehensively analyze the key factors influencing university rankings and assess their impact on Nanyang Technological University's (NTU) recent decline in rankings. By leveraging relevant data and employing advanced analytical techniques, this project aims to identify critical areas for improvement and provide actionable insights to help NTU strategically enhance its ranking position. Ultimately, our goal is to assist NTU in regaining and surpassing its former rank by making data-informed decisions and implementing targeted improvements across various aspects of the institution.

## Web Scraping

I utilized the Python Selenium and BeautifulSoup libraries to retrieve information from two distinct sections of a web page. To initiate the process, I configured a Selenium driver to launch the web page and wait for a specific table to become visible within the Document Object Model (DOM). Subsequently, I transformed this DOM into a BeautifulSoup object.

Following this step, I captured the well-structured HTML output and saved it in a text file. I used BeautifulSoup to extract the precise data I required from the web page. Initially, I made an attempt to directly parse the HTML page into a BeautifulSoup object, but this approach did not yield the expected results. It became evident that the underlying HTML contained only raw HTML code, devoid of any table content which was confirmed after investigation through Google Dev Tools Network Tab. To address this challenge, I devised a workaround, leveraging Selenium to await the dynamic injection of table content into the table before extraction.

The data obtained was subsequently written into a CSV file with a customized header. The script iterated through each row in the BeautifulSoup object, collected the text content of each element, and eliminated any duplicates. Prior to appending each row to the CSV file, some data cleaning and modifications were performed. After processing one section of the web page, the script paused for a 2-second interval and gracefully terminated the driver. It then repeated this process for the subsequent web page section, extracting and writing data into a separate CSV file.

## Findings

Based on a regression model analysis, we derived that a 0.303762 unit change in average overall score is associated with 1 unit increase in teaching, holding all else constant, while a 0.308450 unit change in average overall score is associated with 1 unit increase in research, which represents the highest unit change in average overall score compared to the other score components. NTU can strategically direct its efforts towards specific areas within these two score factors. One example could be the reputation surveys (for teaching and research), which carry substantial weight in each component. These reputation surveys are conducted independently and gauge the perceived prestige of institutions in teaching and research excellence. NTU could explore avenues such as recruiting and retaining more experienced faculty to develop and enhance curricula to keep pace with evolving educational trends. Additionally, the institution could actively seek and incorporate student feedback to identify areas for improvement aimed at enhancing the educational experience.

The top 200 universities have statistically significantly higher average FTE students as compared to the rest of the universities (201–1501+). It follows from our understanding of higher education that students would prefer to enrol in universities with accreditation and higher rankings, as this enhances their employability prospects upon graduation. The implications for NTU are worth considering, especially concerning the staff-to-student ratio. With a growing interest in these top 200 universities, there is a need for appropriate resource allocation to support students throughout their educational journeys, even if it means adjusting the student-to-staff ratio. This includes increasing the number of faculty members and other supporting staff, particularly in areas such as career counselling, to ensure a fulfilling and enriching learning experience. Such enhancements would allow for more individualised attention and care while improving the overall quality of education.

The difference in the average student per staff between the top 200 universities and the rest of the universities is not statistically significant. However, it remains a crucial factor for decision-making at NTU as it directly impacts the cost of serving each student. It is advisable to benchmark this metric against peer institutions that have higher rankings. By doing so, NTU can identify areas for operational improvement. For instance, when comparing the average student per staff for universities ranked 1–10 (9.65) with NTU's metric (15.1), there is a notable difference. NTU's metric is approximately 40% higher. This suggests potential areas for enhancement through process improvements and streamlining to reduce reliance on a large number of supporting staff.

While the average MF_Ratio appears relatively consistent around the mean, a notable trend emerges as university rank decreases: an increase in the presence of outliers. This statistic, calculated as the ratio of male proportion to female proportion (where male + female = 100), highlights that lower-ranking universities exhibit a greater disparity between the percentages of males and females. For example, an MF_Ratio of 5.25 indicates that males are five times more represented in the population compared to females, with a proportion of 16% females and 84% males. NTU could strive for an MF_Ratio of <= 1, achieving a balanced gender ratio with equal proportions of males and females across the entire university. Achieving this balance could involve implementing policies and initiatives to encourage female participation in fields that are traditionally male-dominated, such as STEM disciplines.

The number of international students is moderately correlated with the overall score, while the number of international students is highly correlated with the international outlook, which is one factor contributing to the overall score. The International Outlook metric measures the proportion of international students in the university, reflecting the institution's ability to succeed on the global stage. A higher number of international students may indicate that the university may enjoy greater accreditation and recognition worldwide, as students are more willing to travel far from their home countries to enrol in such institutions. The implication for NTU is to continue its overseas recruitment efforts, attracting students from across Southeast Asia and beyond. This strategy can enhance NTU's brand image and global recognition. Additionally, NTU can expand support for international exchange programmes with partner universities worldwide, fostering interactions between diverse cultures and individuals from various backgrounds.

## Acknowledgements

Credits/ Sources: 
https://www.timeshighereducation.com/world-university-rankings/world-university-rankings-2023-methodology

https://www.timeshighereducation.com/world-university-rankings/2023/world-ranking

https://chat.openai.com/share/c981a0dc-a75d-4589-9e8e-a8832cdb8901


