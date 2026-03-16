# ============================================================
# marvel_dataset.R
# Marvel MCU Movies - Box Office & Reviews Analysis
# Author: D. Shivani
# Built: November 2024
# ============================================================

# Install dependencies (run once)
# install.packages(c("ggplot2", "dplyr", "psych", "janitor", "lubridate"))

library(ggplot2)
library(dplyr)
library(psych)
library(janitor)
library(lubridate)


# ------------------------------------------------------------
# 1. Load and clean box office data
# ------------------------------------------------------------

marvel <- read.csv("data/marvel.csv")

# Check column names
colnames(marvel)

# Remove currency symbols and convert financial columns to numeric
marvel$Budget.in.millions <- as.numeric(gsub("\\$", "", marvel$Budget.in.millions))
marvel$Opening.weekend.in.North.America <- as.numeric(gsub("\\$", "", marvel$Opening.weekend.in.North.America))
marvel$North.America <- as.numeric(gsub("\\$", "", marvel$North.America))
marvel$Other.territories <- as.numeric(gsub("\\$", "", marvel$Other.territories))
marvel$Worldwide <- as.numeric(gsub("\\$", "", marvel$Worldwide))

# Convert budget from millions to full value
marvel$Budget.in.millions <- marvel$Budget.in.millions * 1000000

# Parse release date into proper date format
marvel$Release.date.in.US <- as.Date(marvel$Release.date.in.US, format = "%B %d %Y")

# Rename columns and clean names for consistency
marvel <- marvel %>%
  select(-c(Distributors)) %>%
  rename(
    movie_names                   = Title,
    release_date_in_US            = Release.date.in.US,
    budget                        = Budget.in.millions,
    opening_weekend_North_America = Opening.weekend.in.North.America
  ) %>%
  clean_names()

# Replace missing budget values with 0
marvel <- marvel %>%
  mutate(budget = ifelse(is.na(budget), 0, budget))

# Remove incomplete rows at the end of the dataset
marvel <- marvel[-c(65, 66), ]

# Statistical summary
describe(marvel)


# ------------------------------------------------------------
# 2. Load and clean reviews data
# ------------------------------------------------------------

reviews <- read.csv("data/marvel_reviews.csv")

# Clean Rotten Tomatoes — remove parenthetical notes, percentages, footnotes
reviews$Rotten.Tomatoes <- gsub("\\s*\\([^\\)]+\\)", "", reviews$Rotten.Tomatoes)
reviews$Rotten.Tomatoes <- gsub("%", "", reviews$Rotten.Tomatoes)
reviews$Rotten.Tomatoes <- gsub("\\[\\d+\\]", "", reviews$Rotten.Tomatoes)

# Clean Metacritic and CinemaScore — remove footnotes and parenthetical notes
reviews$Metacritic <- gsub("\\s*\\([^\\)]+\\)", "", reviews$Metacritic)
reviews$Metacritic <- gsub("\\[\\d+\\]", "", reviews$Metacritic)
reviews$CinemaScore <- gsub("\\[\\d+\\]", "", reviews$CinemaScore)

# Rename, convert scores to numeric, and clean column names
reviews <- reviews %>%
  rename(movie_names = Film) %>%
  mutate(
    Rotten.Tomatoes = as.numeric(Rotten.Tomatoes),
    Metacritic      = as.numeric(Metacritic)
  ) %>%
  clean_names()

# Remove the duplicate film column created by clean_names
reviews <- reviews %>%
  select(-c(film))

# Replace empty strings with NA and remove incomplete rows
reviews[reviews == ""] <- NA
reviews <- na.omit(reviews)

# Statistical summary
describe(reviews)


# ------------------------------------------------------------
# 3. Join datasets
# ------------------------------------------------------------

# Combine box office and reviews data on movie name
marvel_v2 <- inner_join(marvel, reviews, by = "movie_names")

# Extract year and month from release date for time-based analysis
marvel_v2 <- marvel_v2 %>%
  mutate(
    release_date_in_us = as.Date(release_date_in_us),
    year               = year(release_date_in_us),
    month              = month(release_date_in_us)
  ) %>%
  select(-c(cinema_score))

# Final structure check
str(marvel_v2)
describe(marvel_v2)


# ------------------------------------------------------------
# 4. Visualisations
# ------------------------------------------------------------

# Plot 1: Budget vs worldwide box office
# Does spending more on production lead to higher revenue?
ggplot(data = marvel_v2, aes(x = budget, y = worldwide)) +
  geom_point() +
  geom_smooth() +
  labs(
    title = "Budget vs. Box Office Collection",
    x     = "Production Budget (USD)",
    y     = "Worldwide Collection (USD)"
  )

# Plot 2: Rotten Tomatoes vs Metacritic
# Do the two major critic platforms tend to agree?
ggplot(data = marvel_v2, aes(x = rotten_tomatoes, y = metacritic)) +
  geom_point() +
  geom_smooth() +
  labs(
    title = "Rotten Tomatoes vs. Metacritic",
    x     = "Rotten Tomatoes (%)",
    y     = "Metacritic Score"
  )

# Plot 3: Top 20 most profitable movies
# Profit = worldwide revenue minus production budget
marvel_v2 %>%
  mutate(profit_margin = worldwide - budget) %>%
  arrange(desc(profit_margin)) %>%
  slice(1:20) %>%
  ggplot(aes(x = profit_margin, y = reorder(movie_names, profit_margin), fill = profit_margin)) +
  geom_col() +
  labs(
    title    = "Top 20 Most Profitable Marvel Movies",
    subtitle = "Profit = worldwide revenue minus production budget (USD)",
    x        = "Profit (USD)",
    y        = NULL
  )

# Plot 4: Top 20 highest Rotten Tomatoes scores
marvel_v2 %>%
  arrange(desc(rotten_tomatoes)) %>%
  slice(1:20) %>%
  ggplot(aes(x = rotten_tomatoes, y = reorder(movie_names, rotten_tomatoes), fill = rotten_tomatoes)) +
  geom_col() +
  labs(
    title = "Top 20 Marvel Movies by Rotten Tomatoes Score",
    x     = "Rotten Tomatoes (%)",
    y     = NULL
  )

# Plot 5: Rotten Tomatoes vs worldwide revenue
# Does critical acclaim drive box office performance?
ggplot(data = marvel_v2, aes(x = rotten_tomatoes, y = worldwide, color = worldwide)) +
  geom_point() +
  geom_smooth() +
  labs(
    title = "Rotten Tomatoes Score vs. Worldwide Revenue",
    x     = "Rotten Tomatoes (%)",
    y     = "Worldwide Revenue (USD)"
  )

# Plot 6: Metacritic vs worldwide revenue
ggplot(data = marvel_v2, aes(x = metacritic, y = worldwide, colour = worldwide)) +
  geom_point() +
  geom_smooth() +
  labs(
    title = "Metacritic Score vs. Worldwide Revenue",
    x     = "Metacritic Score",
    y     = "Worldwide Revenue (USD)"
  )
