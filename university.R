
setwd("~/Downloads/web_scraping")
install.packages(c("data.table","corrplot","ggplot2","car"))
library(data.table)
library(corrplot)
library(ggplot2)
library(car)
# ---------------------
# The objective of this data analytics project is to comprehensively analyze the key factors influencing university rankings and assess their impact on Nanyang Technological University's (NTU) recent decline in rankings. By leveraging relevant data and employing advanced analytical techniques, this project aims to identify critical areas for improvement and provide actionable insights to help NTU strategically enhance its ranking position. Ultimately, our goal is to assist NTU in regaining and surpassing its former rank by making data-informed decisions and implementing targeted improvements across various aspects of the institution.
# ---------------------

# Import Web Scrapped Data
scores = fread("scraped_data_scores.csv",fill = T)
stats = fread("scraped_data_stats.csv",fill = T)

# Merge Data on University Name
uni = merge.data.table(scores,stats, by.x="UniversityName", by.y="UniversityName", sort= F)

# ---------------------
# Data Cleaning
# ---------------------

# Remove Duplicated Rows
uni.c <- uni[, -c("Rank.y", "Country.y", "F:M_Ratio")]

# Renaming Rows
colnames(uni.c)[2] <- "Rank"
colnames(uni.c)[3] <- "Country"

# Remove Unranked Universities 
uni.c = uni.c[Rank!='Reporter',]

# Check for Duplicated Records 
uni.c[duplicated(uni.c)]
# No duplicated Records
# Empty data.table (0 rows and 14 cols): UniversityName,Rank,Country,Overall,Teaching,Research...

summary(uni.c)
# Rank Column will be ignored for all applications, Rank determined by Overall Score which is reflected in Overall Column
# Country Column Data Type = Char
# Overall Column Data Type = Char
# InternationalOutlook NA's:24 
# No.FTE_Students Data Type = Char
# No.Student_Per_Staff Data Type = Char
# InternationalStudents Data Type = Char
# F_Ratio / M_Ratio are derived from each other, a simplier statistic can be calculated from the ratio of the two.
# F_Ratio / M_Ratio NA's:85

# Convert Country Column to Factor
uni.c$Country <- as.factor(uni.c$Country)

# Convert FTE_Students Column to Numeric
uni.c$No.FTE_Students <- as.numeric(gsub(",", "", uni.c$No.FTE_Students))

# Convert No.Student_Per_staff to Numeric
uni.c$No.Student_Per_Staff <- as.numeric(uni.c$No.Student_Per_Staff)

# Convert InternationalStudents to Numeric
uni.c$InternationalStudents <- as.numeric(gsub("%", "", uni.c$InternationalStudents)) / 100

# Create new Statistic: Ratio of Males / Females
uni.c$MF_ratio = uni.c$M_Ratio / uni.c$F_Ratio

# Remove Unwanted Columns
uni.c <- uni.c[, -c("F_Ratio","M_Ratio")]

# Calculate Mean for Universities below the Rank 200
calculate_mean_from_range <- function(range_str) {
  range_split <- strsplit(range_str, "–", fixed = TRUE)
  lower_bound <- as.numeric(range_split[[1]][1])
  upper_bound <- as.numeric(range_split[[1]][2])
  return(mean(c(lower_bound, upper_bound)))
}

# Create a new column 'Overall_Calc' based on conditions
uni.c$Overall_Calc <- ifelse(
  !grepl("[^0-9.-]", uni.c$Overall), # Check if data can be converted to numeric
  as.numeric(uni.c$Overall),        # If yes, convert to numeric
  sapply(uni.c$Overall, calculate_mean_from_range)  # If no, calculate mean from range
)

# Remove Unwanted Columns
uni.c <- uni.c[, -c("Overall")]

summary(uni.c)

# Remove "=" from Rank
uni.c$Rank_Cleaned <- gsub("=", "", uni.c$Rank)


convert_to_buckets <- function(rank) {
  rank_numeric <- as.numeric(rank)
  if (!is.na(rank_numeric)) {
    if (rank_numeric >= 1 && rank_numeric <= 10) {
      return("1-10")
    } else if (rank_numeric >= 11 && rank_numeric <= 20) {
      return("11-20")
    } else if (rank_numeric >= 21 && rank_numeric <= 30) {
      return("21-30")
    } else if (rank_numeric >= 31 && rank_numeric <= 40) {
      return("31-40")
    } else if (rank_numeric >= 41 && rank_numeric <= 50) {
      return("41-50")
    } else if (rank_numeric >= 51 && rank_numeric <= 100) {
      return("51-100")
    } else if (rank_numeric >= 101 && rank_numeric <= 150) {
      return("101-150")
    } else if (rank_numeric >= 151 && rank_numeric <= 200) {
      return("151-200")
    } else {
      return(rank)
    }
  } else {
    return(rank)
  }
}

# Create Rank Buckets 
uni.c$Bucket <- sapply(uni.c$Rank_Cleaned, convert_to_buckets)

# Calculate Mean International Outlook Statistic Based on Group Rank Buckets
mean_international_outlook <- ave(uni.c$InternationalOutlook, uni.c$Bucket, 
                                  FUN = function(x) mean(x, na.rm = TRUE))

# Impute missing values in 'InternationalOutlook' with the group mean
uni.c$InternationalOutlook_Cleaned <- ifelse(is.na(uni.c$InternationalOutlook),mean_international_outlook, uni.c$InternationalOutlook)


# InternationalStudents NAs:1 Karlstad University
uni.c[is.na(InternationalStudents)]$InternationalStudents = mean(uni.c[Bucket=="801–1000",InternationalStudents],na.rm = T)
# Impute with Mean of Group Rank Bucket

uni.c[UniversityName=="Karlstad University"]

summary(uni.c)

# MF_Ratio NAs: 85
uni.c[is.na(MF_ratio),.N]

# Calculate Mean MF Ratio Statistic Based on Group Rank Buckets
mean_mf_ratio <- ave(uni.c$MF_ratio, uni.c$Bucket, 
                                  FUN = function(x) mean(x, na.rm = TRUE))

# Impute missing values in 'MF_ratio' with the group mean
uni.c$MF_ratio_Cleaned <- ifelse(is.na(uni.c$MF_ratio),mean_mf_ratio,uni.c$MF_ratio)

summary(uni.c)

uni.c = uni.c[,-c("Rank","InternationalOutlook","MF_ratio")][,c("UniversityName","Country","Rank_Cleaned","Bucket","Overall_Calc","Teaching","Research","Citations","IndustryIncome","InternationalOutlook_Cleaned","No.FTE_Students","No.Student_Per_Staff","InternationalStudents","MF_ratio_Cleaned")]

colnames(uni.c) <- c("Name","Country","Rank","Bucket","Overall","Teaching","Research","Citations","IndustryIncome","InternationalOutlook","FTE_Students","StudentPerStaff","InternationalStudents","MF_Ratio")

uni.c$Bucket <- factor(uni.c$Bucket, levels = c("1-10", "11-20", "21-30", "31-40", "41-50", 
                                                "51-100", "101-150", "151-200", "201–250", "251–300",
                                                "301–350", "351–400", "401–500", "501–600", "601–800",
                                                "801–1000", "1001–1200", "1201–1500", "1501+"))


# ---------------------
# Analysis
# ---------------------

# The analysis will primarily concentrate on the Top 200 Universities in the World, which constitute a subset of the complete dataset containing over 1501 universities. In specific scenarios, the entire dataset will be employed to explore potential significant differences between the two subsets, namely the top 200 universities and the remaining universities.

uni.c.subset = uni.c[Bucket %in% c("1-10", "11-20", "21-30", "31-40", "41-50", "51-100", "101-150", "151-200")]

cor(uni.c.subset[,-c("Name","Country","Rank","Bucket")])

corrplot(cor(uni.c.subset[,-c("Name","Country","Rank","Bucket")]), type = "lower")

# Correlation indicates the presence of a linear relationship between two variables.
# A high or low correlation does not rule out the possibility of other types of relationships between the two variables, such as exponential, and so on.

# Teaching, Research, and Citations exhibit a strong association with the Overall Score.

ggplot(data=uni.c.subset, aes(Overall,Teaching, color=Bucket)) + geom_point() + geom_smooth(method = "lm", se = FALSE, aes(group = 1))
# Strong Linear Relationship between Overall and Teaching

ggplot(data=uni.c.subset, aes(Overall,Research, color=Bucket)) + geom_point() + geom_smooth(method = "lm", se = FALSE, aes(group = 1))
# Strong Linear Relationship between Overall and Research

ggplot(data=uni.c.subset, aes(Overall,Citations, color=Bucket)) + geom_point() + geom_smooth(method = "lm", se = FALSE, aes(group = 1))
# Strong Linear Relationship between Overall and Citations

# Industry Income, International Outlook, and International Students demonstrate a moderate association with the Overall Score.

ggplot(data=uni.c.subset, aes(Overall,IndustryIncome, color=Bucket)) + geom_point() + geom_smooth(method = "lm", se = FALSE, aes(group = 1))
# Weak Linear Relationship between Overall and IndustryIncome

# Interestingly, International Students also exhibit a moderate association with the Overall Score.

ggplot(data=uni.c.subset, aes(Overall,InternationalOutlook, color=Bucket)) + geom_point() + geom_smooth(method = "lm", se = FALSE, aes(group = 1))
# Weak Linear Relationship between the two factors

ggplot(data=uni.c.subset, aes(Overall,InternationalStudents, color=Bucket)) + geom_point() + geom_smooth(method = "lm", se = FALSE, aes(group = 1))
# Weak Linear Relationship between the two factors

# Other factors like FTE_Students, StudentPerStaff, International Students, and MF_Ratio show a weak association with the Overall Score.

# It's not surprising that there is some correlation between these performance indicators and the Overall Score, as each of these performance indicators contributes to an aspect of the Overall Score, with each having its own distinct categories.

# Linear Regression Model to explore and explain the relationship between the various independent variable and the dependent variable (Overall Score)

summary(lm(Overall~.-Name-Country-Rank-Bucket,data=uni.c.subset))
# Fine Tune the Model to exclude Independent Variables X that are statistically significant in predicting the output of Y

model = lm(Overall~.-Name-Country-Rank-Bucket-FTE_Students-InternationalStudents-MF_Ratio-StudentPerStaff,data=uni.c.subset)
summary(model)

par(mfrow = c(2,2))

plot(model)

# Top Left Chart: Residuals vs Fitted - Testing the Assumption of Linear Association between Y and Xs
# There are no discernible patterns in the residuals, indicating that the data points align well with a linear relationship. The model adequately captures any linear relationships, leaving no significant non-linear associations unaccounted for in the residuals.

# Top Right Chart: Normal Q-Q - Testing the Assumption that Errors Follow a Normal Distribution with Mean 0
# The residuals closely follow the reference line, with no substantial deviations observed. While some outliers are present in previous charts (cases 11, 14, and 148), they do not strongly impact the overall normality assumption.

# Bottom Left Chart: Scale-Location - Testing the Assumption that Errors Are Independent of X and Have Constant Standard Deviation
# The residuals appear randomly scattered along the x-axis, becoming less dense towards the tail end. Similar outliers, as noted in previous charts (cases 11, 14, and 148), are also evident here.

# Bottom Right Chart: Residuals vs Leverage - Identifying Influential Outliers
# One potential influential outlier, case 164, has been detected.

# Summary of Linear Regression Model Excluding Outlier (case 164):

summary(lm(Overall~.-Name-Country-Rank-Bucket-FTE_Students-InternationalStudents-MF_Ratio-StudentPerStaff,data=uni.c.subset[-164,]))

# Removing the outlier (case 164) from the overall regression model does not significantly affect the model's consistency or explanatory power. Therefore, we opt to retain this outlier to preserve the relationship in the analysis for clarity and continuity.

par(mfrow = c(1,1))

vif(model)
#Teaching             Research            Citations       IndustryIncome InternationalOutlook 
#6.683900             6.989191             1.228932             1.316203             1.336117

# Concerns regarding multicollinearity arise when the variance inflation factor (VIF) calculated for teaching and research exceeds a value of 5. Some researchers only consider a VIF value in excess of 10 to represent the presence of mutlicollinearity. There is no consensus over the absolute value of the VIF. Multicollinearity occurs when one variable, such as teaching, can be expressed as a linear combination of the other independent variables in the model (research, citations, industry income, and international outlook).

# However, it's important to note that each of these factors measures a distinct aspect of the overall score. Omitting any one of these variables, be it teaching or research, would result in an incomplete understanding of the relationships between these variables and the overall score. Therefore, I have chosen to retain these variables in the model to ensure that we capture a comprehensive picture of these relationships. For applications of this model henceforth, we will keep the model devoid of any multicollinearity concerns.

# Predicted Overall Score = 1.055586 + 0.303762 * Teaching + 0.308450 * Research + 0.279185 * Citations + 0.021412 * IndustryIncome + 0.079060 * InternationalOutlook

# A 0.303762 Unit Change in Average Overall Score associated with 1 unit Increase in Teaching, holding all else constant.
# A 0.308450 Unit Change in Average Overall Score associated with 1 unit Increase in Research, holding all else constant.
# A 0.279185 Unit Change in Average Overall Score associated with 1 unit Increase in Citations, holding all else constant.
# A 0.021412 Unit Change in Average Overall Score associated with 1 unit Increase in IndustryIncome, holding all else constant.
# A 0.079060 Unit Change in Average Overall Score associated with 1 unit Increase in InternationalOutlook, holding all else constant.

# Implications for NTU: A one-unit change in Teaching and Research Scores yields the highest unit change in Average Overall Scores compared to the other score components. NTU can strategically direct its efforts towards specific areas within these two score factors. One example could be the reputation surveys (for teaching and research), which carry substantial weightage in each component. These reputation surveys are conducted independently and gauge the perceived prestige of institutions in teaching and research excellence. NTU could explore avenues such as recruiting and retaining more experienced faculty to develop and enhance curricula to keep pace with evolving educational trends. Additionally, the institution could actively seek and incorporate student feedback to identify areas for improvement aimed at enhancing the educational experience. 

ggplot(data=uni.c, aes(Bucket,FTE_Students)) + geom_boxplot()

ggplot(data = uni.c[,mean(FTE_Students),Bucket], aes(Bucket, V1)) + geom_col()

mean(uni.c$FTE_Students)

# There is no discernible pattern between FTE Students and the Rank Buckets.
# Across the various Rank Buckets, FTE Students around the mean of 22505.19.

ggplot(data=uni.c, aes(Overall,FTE_Students, color=Bucket)) + geom_point() + geom_smooth(method = "lm", se = FALSE, aes(group = 1))
ggplot(data=uni.c.subset, aes(Overall,FTE_Students, color=Bucket)) + geom_point() + geom_smooth(method = "lm", se = FALSE, aes(group = 1))

# There is no clear relationship between FTE Students and the Overall Scores
# FTE Students is not one of the differentiating factor between the Ranks

t.test(uni.c.subset$FTE_Students, uni.c[!(Bucket %in% c("1-10", "11-20", "21-30", "31-40", "41-50", "51-100", "101-150", "151-200"))]$FTE_Students, alternative = "greater")
# H0: X(1-200) - x(201-1501+) <= 0
# H1: X(1-200) - x(201-1501+) > 0
# p-value: 3.166e-06
# Strong Evidence to reject the Null Hypothesis, Accept the Alternative
# Top 200 Universities have Statistically Significantly Higher Average FTE Students as compared to the Rest of the Universities (201 - 1501+).

# It is not surprising that a significant number of students prefer to enroll in universities with accreditation and higher rankings, as this enhances their employability prospects upon graduation. The enrollment numbers for the top 200 universities far exceed those of the remaining institutions. The implications for NTU are worth considering, especially concerning the staff-to-student ratio. With a growing interest in these top 200 universities, there is a need for appropriate resource allocation to support students throughout their educational journeys, even if it means adjusting the student-to-staff ratio. This includes increasing the number of faculty members and other supporting staff, particularly in areas such as career counseling, to ensure a fulfilling and enriching learning experience. Such enhancements would allow for more individualized attention and care while improving the overall quality of education.


ggplot(data=uni.c, aes(Bucket,StudentPerStaff)) + geom_boxplot()

ggplot(data = uni.c[,mean(StudentPerStaff),Bucket], aes(Bucket, V1)) + geom_col()

ggplot(data=uni.c, aes(Overall,StudentPerStaff, color=Bucket)) + geom_point()

cor(uni.c$Overall,uni.c$StudentPerStaff)
# -0.01508977
# Weak Linear Relationship between the two Factors. 
# No relationship between the StudentPerStaff and Overall Score

t.test(uni.c.subset$StudentPerStaff,mu=mean(uni.c[!(Bucket %in% c("1-10", "11-20", "21-30", "31-40", "41-50", "51-100", "101-150", "151-200"))]$StudentPerStaff))
# H0: X(1-200) = x(201-1501+)
# H1: X(1-200) =/ x(201-1501+)
# p-value = 0.3233
# Outcome: Unable to reject the Null Hypothesis, indicating that the difference in the average StudentPerStaff between the Top 200 Universities and the rest of the Universities is not statistically significant.

uni.c[,.(mean=mean(StudentPerStaff)),Bucket]
# Bucket     mean
# 1:      1-10  9.65000
# 2:     11-20 11.41000
# 3:     21-30 13.15000
# 4:     31-40 18.04000
# 5:     41-50 19.60000
# 6:    51-100 19.08000
# 7:   101-150 18.80600
# 8:   151-200 19.00600
# ...

uni.c[Name=="Nanyang Technological University, Singapore",StudentPerStaff]
# 15.1

# Although the StudentPerStaff metric did not show statistical significance, it remains a crucial factor for NTU as it directly impacts the cost of serving each student. It is advisable to benchmark this metric against peer institutions that have higher rankings. By doing so, NTU can identify areas for operational improvement. For instance, when comparing the average StudentPerStaff for Universities ranked 1-10 (9.65) with NTU's metric (15.1), there is a notable difference. NTU's metric is approximately 40% higher. This suggests potential areas for enhancement through process improvements and streamlining to reduce reliance on a large number of supporting staff.

ggplot(data = uni.c[,.(Avg_MF_Ratio=mean(MF_Ratio)),Bucket], aes(Bucket, Avg_MF_Ratio)) + geom_col()
ggplot(data=uni.c.subset, aes(Overall,MF_Ratio, color=Bucket)) + geom_point()
ggplot(data = uni.c, aes(Bucket, MF_Ratio)) + geom_boxplot() + scale_y_continuous(limits = c(NA,7.5))

# No discernable pattern in the Average MF_Ratio between Top 200 Ranking Universities as compared to the rest of the Universities. 
# While the average MF_Ratio appears relatively consistent, a notable trend emerges as university rank decreases: an increase in the presence of outliers. This statistic, calculated as the ratio of Male Proportion to Female Proportion (where Male + Female = 100), highlights that lower-ranking universities exhibit a greater disparity between the percentages of males and females. For example, an MF_Ratio of 5.25 indicates that males are five times more represented in the population compared to females, with a proportion of 16% females and 84% males. 

mean(uni.c$MF_Ratio)
# 1.174364
mean(uni.c.subset$MF_Ratio)
# 1.013314
uni.c[Name=="Nanyang Technological University, Singapore",MF_Ratio]
# 1.083333

# The implication for NTU is to strive for an MF_Ratio of <= 1, achieving a balanced gender ratio with equal proportions of males and females across the entire university. Achieving this balance could involve implementing policies and initiatives to encourage female participation in fields that are traditionally male-dominated, such as STEM disciplines.

cor(uni.c$Overall,uni.c$InternationalStudents)
# 0.5465875
cor(uni.c$InternationalOutlook,uni.c$InternationalStudents)
# 0.7997381
ggplot(data=uni.c.subset, aes(Overall,InternationalStudents, color=Bucket)) + geom_point() + geom_smooth(method = "lm", se = FALSE, aes(group = 1))
ggplot(data=uni.c.subset, aes(InternationalOutlook,InternationalStudents, color=Bucket)) + geom_point() + geom_smooth(method = "lm", se = FALSE, aes(group = 1))

# Number of InternationalStudents Moderately Correlated with Overall Score

# Number of InternationalStudents High Correlated with InternationalOutlook, which is one factor componenet of Overall Score
# The InternationalOutlook metric measures the proportion of international students in the university, reflecting the institution's ability to succeed on the global stage. A higher number of international students indicates that the university may enjoy greater accreditation and respect worldwide, as students are more willing to travel far from their home countries to enroll in such institutions. The implication for NTU is to continue its overseas recruitment efforts, attracting students from across Southeast Asia and beyond. This strategy can enhance NTU's brand image and global recognition. Additionally, NTU can expand support for international exchange programs with partner universities worldwide, fostering interactions between diverse cultures and individuals from various backgrounds

# Sources: https://www.timeshighereducation.com/world-university-rankings/world-university-rankings-2023-methodology

