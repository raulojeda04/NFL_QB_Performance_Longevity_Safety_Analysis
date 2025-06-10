# Project Background

The National Football League (NFL), established in 1920 as the American Professional Football Association (APFA), is the most prominent professional American football league in the United States. 

The NFL has evolved significantly over the last two decades, with a major emphasis placed on player safety, particularly for the quarterback position. Since 2002, a series of rule changes have been implemented to protect quarterbacks from dangerous hits, altering the dynamics of the passing game. The years with and without these major rules were designated into four eras:
  * **Pre-Rules (<2002)**: Era before major saftey rules were implemented 
  * **Early Protection (2002-2008)**: Era where new saftey rules were established to protect the quarterback
  * **Defenseless Player Focus (2009-2017)**: Era where some of the prior rules were re-clarified to re-define a "defenseless player"
  * **Body Weight Emphasis (2018+)**: Era emphasizing the Body Weight Rule established prior and is the current era of football (Modern Era)

This project thoroughly analyzes quarterback passing and longevity data from 1976-2024 to uncover critical insights into how these rule changes correlate with shifts in on-field performance and career arcs.

Insights and recommendations are provided on the following key areas:

-   **Performance & Efficiency Trends:** Evaluation of historical passing metrics, focusing on Passer Rating, Completion Percentage, Yards Per Attempt, Touchdown %, and Interception %.
-   **Risk vs. Reward Profile:** An analysis of how passing strategy has evolved, balancing aggressive downfield passing against the risk of turnovers.
-   **Safety Impact:** An assessment of how sack rates have changed over time and across different rule eras.
-   **Longevity Dynamics:** An evaluation of how quarterback age, games played, and career length have trended, with a specific focus on different age cohorts.

 
An interactive Power BI dashboard for this project can be found [here](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/main/passing_final.pbix)

The Python scripts used for web scraping can be found [here](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/tree/main/python).

The SQL queries utilized to clean, organize, and prepare data for the dashboard can be found **[here](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/4ed84311c361178be5516e450e2a110115eb5451/sql/passing_cleaning.sql)**.

---

# Data Structure & Pipeline Overview

The dataset for this project was created by web scraping quarterback passing statistics for every season from 1976 to 2024 from [pro-football-reference.com](https://www.pro-football-reference.com/years/2024/passing.htm). The initial raw data was scraped using Python and then imported into a SQL database for extensive cleaning and preparation.

The final, cleaned dataset is a single table containing player-season level data, with key columns including Player, Year, Team, Age, Games Played, and a comprehensive set of passing and sack statistics. This cleaned data was then modeled in Power BI, where custom columns and DAX measures were created to power the analysis.

The SQL queries utilized to clean the data can be found **[here.](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/4ed84311c361178be5516e450e2a110115eb5451/sql/passing_cleaning.sql)**.

---

# Executive Summary

### Overview of Findings

The analysis reveals a significant and positive correlation between the implementation of 21st-century QB safety rules and improvements in passing performance. Key performance indicators show that passing has become drastically more efficient and less risky. Sack rates have declined, indicating a safer environment. While overall career longevity metrics are skewed by active players in the modern era, a deeper dive reveals that **veteran quarterbacks (ages 30+) are playing more and sustaining high levels of production for longer** than in previous eras.

Below is the overview page from the Power BI dashboard. More examples are included throughout this summary.

![Dashboard Overview](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/main/images/overview_summary.png) 


### Performance & Efficiency Trends:

* **Quarterback passing efficiency has substantially improved.** Comparing the Pre-Rules Era (pre-2002) to the Modern Era (2018+), **Passer Rating increased by 20.79%**.

* **Accuracy shows a consistent, stepwise increase across each rule era.** Quarterback **Completion Percentage rose from 55.5% in the Pre-Rules Era to 63.8% in the Modern Era**, demonstrating a clear improvement in fundamental passing skill.

* The most dramatic change was in ball security, as **Interception Percentage plummeted by 39.1%** when comparing the Pre-Rules and Modern eras.

![Performance Trends Over Time](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/main/images/trends_over_time.png) ![Performance Trends By Era](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/main/images/trends_by_era.png)

### Risk vs. Reward Profile:

* The strategic profile of the NFL passing game has fundamentally shifted. The analysis shows a clear evolution from a **high-risk, moderate-reward profile in earlier periods to a significantly lower-risk, higher-reward profile in recent eras.**
  * Pre-Rules Era: about **4.0% INT rate** for around **6.8  Yards Per Attempt**
  * Modern Era: about **2.4% INT rate** for around **7.0 Yards Per Attempt**

* In the scatter plot analysis, the passing game moved from the bottom-right quadrant (higher INT%, lower Y/A) in the 1970s and Pre-Rules Era to the **optimal top-left quadrant (lower INT%, higher Y/A) in the 2010s, 2020s, and the latest rule eras.**

* This indicates that modern quarterbacks are not just playing safer; they have become **efficiently aggressive**, maximizing yardage while minimizing turnovers in the protected environment.

![Risk vs. Reward](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/main/images/risk_reward.png) 


### Safety & Longevity Dynamics:

* While overall career longevity metrics are skewed by active players, filtering for veteran cohorts reveals the true trend. For quarterbacks [**aged 35 and older**](images/overview_summary_35+.png), their average Games Played per season increased by **7.4%** and their Career Longevity metric (seasons played so far) grew by **31%** when comparing the Pre-Rules and Modern Eras.

* **Sack rates, a key proxy for player safety, have declined.** The overall [**Sack Percentage decreased by 9.5%**](images/overview_summary.png) from the Pre-Rules Era to the Modern Era. The trend line shows consistent declines that correlate with the introduction of new rule eras.

* **Veteran quarterbacks are carrying a larger share of the offensive workload.** The contribution of QBs aged 35 and older to the league's total passing attempts grew from **10.5%** in the Pre-Rules Era to **16.1%** in the Modern Era.

![Safety and Longevity](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/de39e37e0559dac9a77a56483875130179268f21/images/saftey_career_impact.png) ![Passing Attempts Age Breakdown by Era](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/main/images/passing_attempts_age_proportions.png) 

For further investigation into Age Groups, click below:
* [30+ KPIs](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/main/images/overview_summary_30%2B.png)
* [30+ Playing Careers](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/main/images/avg_age_longevity_30%2B.png)
* [35+ KPIs](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/main/images/overview_summary_35%2B.png)
* [35+ Playing Careers](https://github.com/raulojeda04/NFL_QB_Performance_Longevity_Safety_Analysis/blob/main/images/avg_age_longevity_35%2B.png)


## Recommendations

Based on the uncovered insights, the following recommendations are provided:

* **Prioritize Rule Clarity and Consistent Application.** The analysis showed that eras involving the *re-clarification* of rules (**Defenseless Player Focus (2009-2017)** saw significant performance jumps. This suggests that ensuring rules are clearly understood and consistently enforced by officials is as critical as creating new ones.


* **Formalize Rule Implementation Timelines.** Given that some rules appeared to be implemented quickly following specific incidents, the NFL should consider a more structured, year-long cycle of proposal, feedback, and refinement for major new safety rules to ensure they are robust and well-understood before being adopted.

* **Further Investigate Cohort-Specific Longevity Trends.** The insights regarding veteran QB longevity are significant. Further analysis focusing on specific player cohorts (e.g., all QBs drafted between 2000-2005) could provide an even clearer picture of career extension and inform future player welfare strategies.
 
* **Continue Data-Driven Review of Rule Impacts.** The NFL Competition Committee should continue to leverage data analytics to monitor the effects of rules on safety, game dynamics, and player career arcs to allow for evidence-based adjustments rather than purely reactive changes.
---

## Caveats and Assumptions

* **Correlation vs. Causation:** This analysis identifies strong correlations between rule changes and statistical trends. However, it does not prove causation, as other factors like evolving offensive/defensive schemes, player training, and sports medicine also contribute.
* **Active Player Bias in Longevity Metric:** As stated, the "Average Career Longevity" metric for recent eras is skewed downwards due to the inclusion of many players whose careers are still active. The insights derived from the age distribution and age-group filtered data provide a more reliable indication of longevity trends.
* **Sack Rate as a Safety Proxy:** Sack Rate is a useful proxy for QB safety but does not capture all QB hits, pressures, or the severity of impacts that may lead to injury.
