# Marvel Movies Analysis

**Tools:** R (ggplot2, dplyr, psych, janitor, lubridate)  
**Dataset:** Marvel movies box office and reviews data (included in `/data`)  
**Status:** Complete  
**Built:** November 2024

---

## Overview

This project analyses Marvel Cinematic Universe (MCU) movies to explore the relationship between production budget, box office performance, and critic reviews. It was built as part of my independent R learning journey.

Two datasets are joined and analysed together:
- **marvel.csv** - box office data: budget, opening weekend, North America revenue, worldwide revenue
- **marvel_reviews.csv** - critic scores: Rotten Tomatoes, Metacritic, CinemaScore

---

## Project Structure

```
marvel-movies-analysis/
├── data/
│   ├── marvel.csv            # Box office dataset
│   └── marvel_reviews.csv    # Reviews dataset
├── marvel_dataset.R          # Main analysis script
└── README.md
```

---

## What the script does

**1. Data cleaning**
- Removes currency symbols (`$`) and converts financial columns to numeric
- Converts budget figures to full values (millions → actual)
- Parses release dates into proper date format
- Cleans Rotten Tomatoes and Metacritic scores (removes brackets, percentages)
- Handles missing values and removes incomplete rows

**2. Joins both datasets** on movie name using `inner_join`

**3. Visualisations**
- Budget vs worldwide box office - does spending more earn more?
- Rotten Tomatoes vs Metacritic - do critics agree with each other?
- Top 20 most profitable movies - worldwide revenue minus budget
- Top 20 highest Rotten Tomatoes scores
- Rotten Tomatoes vs worldwide revenue - does critical acclaim drive box office?
- Metacritic vs worldwide revenue - same question, different critic score

---

## Key Questions Explored

- Is there a relationship between production budget and box office success?
- Do critic scores (Rotten Tomatoes, Metacritic) predict worldwide revenue?
- Which Marvel movies were most profitable relative to their budget?

---

## How to Run

```r
# Install dependencies
install.packages(c("ggplot2", "dplyr", "psych", "janitor", "lubridate"))

# Place marvel.csv and marvel_reviews.csv in the same folder
# Then run marvel_dataset.R
```

---

*Project by D. Shivani · Built during independent R learning, November 2024*
