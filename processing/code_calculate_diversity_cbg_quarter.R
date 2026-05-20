# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
#
# Script:    code_calculate_diversity_cbg_quarter.R
#
# Purpose:   Aggregate monthly Advan foot traffic data into quarterly CBG-level
#            diversity indices (Hill numbers q=0,1,2) for three classification levels:
#            - Method 1: experiential service type only
#            - Method 2: ethnic cuisine type only
#            - Method 3: combined (service × ethnicity)
#
# Inputs:    Unpacked CSV files (CBG–restaurant pairs with visit counts) produced by
#            the Python retrieval script `dewey_pipeline.py`. File names must match
#            the pattern "YYYY_MM_unpacked.csv" (e.g., "2019_01_unpacked.csv").
#
# Outputs:   One CSV per quarter (e.g., "2019_Q1.csv") containing one row per CBG
#            with columns: cbg_list, m1q0, m1q1, m1q2, m2q0, m2q1, m2q2,
#                           m3q0, m3q1, m3q2, year, quarter.
#
# Author:    Miao Li and Fangyao Wang
# Date created: 5/23/2024
# Last edited: 2/19/2026 (cleaned for GitHub)
#
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

##### Preliminary #####

# import libraries
library(sf)
library(dplyr)
library(tidyverse)
library(data.table)
library(readr)


# ======================== USER: SET YOUR DATA FOLDER HERE ========================
# Change this to the directory containing the unpacked CSV files.
# Example: data_dir <- "./data"   (if files are in a subfolder "data")
# Example: data_dir <- "C:/MyData/advan_unpacked"
data_dir <- "./data"   # <--- REPLACE with your own path
# =================================================================================

# Get all file names
pattern <- "20[0-2][0-9]_[0-1][0-9]_unpacked\\.csv"
file_names <- list.files(path = data_dir, pattern = pattern, full.names = TRUE)

##### Loop #####

start_time <- Sys.time()
for (j in 1:8) {
  
  # 1:3, 4:6, 7:9, 10:12, 13:15, 16:18, 19:21, 22:24
  m <- 3*j - 2 #start
  n <- 3*j #end
  file_seq <- seq(m, n, by = 1)
  
  year_quarter <- c("2019Q1", "2019Q2", "2019Q3", "2019Q4", 
                    "2023Q1", "2023Q2", "2023Q3", "2023Q4")
  
  
  for (i in file_seq) {
    
    # load data
    temp <- read_delim(file_names[i], show_col_types = F) %>% 
      select(-1)
    
    # 1. Generate census cbg number
    # temp$visitor_home_cbg <- substr(temp$visitor_home_cbg, 1, 11)
    
    # 2. select data using GEOID from shapefile
    # temp <- temp %>%
    #    filter(visitor_home_cbg %in% GEOID)
    
    # 3. Aggregate to census cbg-quarterly level
    if (i == file_seq[1]) {
      quarterly <- temp
    } else {
      quarterly <- rbind(quarterly, temp) %>%
        group_by(placekey, visitor_home_cbg) %>%
        summarise(count = sum(count, na.rm = TRUE),
                  across(everything(), first)) %>%
        ungroup()
    }
  }
  
  # get data for calculating diversity
  data_long <- quarterly
  
  
  # Get restaurant categories
  data <- distinct(data.frame(data_long$placekey, data_long$sub_category, data_long$category_tags))
  colnames(data) <- c('placekey', 'sub_category', 'category_tags')
  
  
  
  ##### Method 1 #####
  data <- data %>% mutate(restaurant_service = case_when(
    
    ### 1. funnel out categories that are distinct and easy-to-categorize
    
    # Fine Dining
    grepl("Fine Dining", data$category_tags) ~ "Fine Dining",
    
    # Fast Food
    grepl("Fast Food", data$category_tags) | grepl("Drive Through", data$category_tags) ~ "Fast Food",
    
    # Buffet
    grepl("Buffet", data$category_tags) | grepl("Cafeteria", data$category_tags) ~ "Buffet",
    
    # Cafe
    grepl("Cafe", data$category_tags) | grepl("Coffee Shop", data$category_tags) ~ "Cafe",
    
    # Casual Dining
    grepl("Casual Dining", data$category_tags) | grepl("Diner", data$category_tags) | grepl("Bistro", data$category_tags) ~ "Casual Dining",
    
    # Bar or Pub
    grepl("Bar or Pub", data$category_tags) | grepl("Sports Bar", data$category_tags) | grepl("Irish Pub", data$category_tags) | grepl("Brewery or Brewpub", data$category_tags) | grepl("Wine Bar", data$category_tags) | grepl("Cocktail Lounge", data$category_tags) | grepl("Beer Garden", data$category_tags) | grepl("Dive Bar", data$category_tags) ~ "Bar or Pub",
    
    
    ### 2. funnel out rest of the Full-Service Restaurants as Casual Dining
    
    # Casual Dining
    grepl("Full-Service Restaurants", data$sub_category) ~ "Casual Dining",
    
    
    ### Thirdly, funnel out the rest of the data
    
    # Snacks
    grepl("Snacks", data$category_tags) | grepl("Dessert", data$category_tags) | grepl("Ice Cream Shop", data$category_tags) | grepl("Gelato Shop", data$category_tags) | grepl("Bakery", data$category_tags) ~ "Snack",
    
    # Fast Casual
    grepl("Counter Service", data$category_tags) | grepl("Hot Dogs", data$category_tags) | grepl("Donut Shop", data$category_tags) | grepl("Chicken Wings", data$category_tags) | grepl("Burgers", data$category_tags) | grepl("Sandwich Shop", data$category_tags) | grepl("Bagel Shop", data$category_tags) | grepl("Salad", data$category_tags) | grepl("Deli", data$category_tags) ~ "Fast-casual",
    
    # Food Truck
    grepl("Truck or Cart", data$category_tags) ~ "Food Truck",
    
    # Specialty Drinks/Tea
    grepl("Bubble Tea Shop", data$category_tags) | grepl("Smoothie & Juice Bar", data$category_tags) | grepl("Beverages", data$category_tags) | grepl("Tea House", data$category_tags) ~ "Specialty Drinks/Tea",
    
    
    TRUE ~ "Other"))
  
  ##### Method 2 #####
  data <- data %>% mutate(restaurant_region = case_when(
    
    # Countries
    grepl("Argentinan", data$category_tags) ~ "Latin American: Argentinan Food",
    grepl("Australian", data$category_tags) ~ "Oceanian: Australian Food",
    grepl("Austrian", data$category_tags) ~ "European: Austrian Food",
    grepl("Brazilian", data$category_tags) ~ "Latin American: Brazilian Food",
    grepl("Burmese", data$category_tags) ~ "Asian: Burmese Food",
    grepl("Canadian", data$category_tags) ~ "North American: Canadian Food",             
    grepl("Chinese", data$category_tags) ~ "Asian: Chinese Food",
    grepl("Cuban", data$category_tags) ~ "Latin American: Cuban Food",    
    grepl("Ethiopian", data$category_tags) ~ "African: Ethiopian Food",
    grepl("Filipino", data$category_tags) ~ "Asian: Filipino Food",
    grepl("French", data$category_tags) | grepl("Creperie", data$category_tags) | grepl("Rotisserie", data$category_tags) ~ "European: French Food",
    grepl("German", data$category_tags) ~ "European: German Food",
    grepl("Greek", data$category_tags) ~ "European: Greek Food",
    grepl("Hungarian", data$category_tags) ~ "European: Hungarian Food",
    grepl("Indian", data$category_tags) ~ "Asian: Indian Food",
    grepl("Irish", data$category_tags) | grepl("Fish & Chips", data$category_tags) | grepl("Irish Pub", data$category_tags) ~ "European: Irish or British Food",
    grepl("Italian", data$category_tags) | grepl("Pizza", data$category_tags) ~ "European: Italian Food",
    grepl("Japanese", data$category_tags) | grepl("Sushi", data$category_tags) ~ "Asian: Japanese Food",
    grepl("Korean", data$category_tags) ~ "Asian: Korean Food",
    grepl("Lebanese", data$category_tags) ~ "Asian: Lebanese Food",
    grepl("Mexican", data$category_tags) ~ "Latin American: Mexican Food",
    grepl("Mongolian", data$category_tags) ~ "Asian: Mongolian Food",     
    grepl("Moroccan", data$category_tags) ~ "African: Moroccan Food",
    grepl("Pakistani", data$category_tags) ~ "Asian: Pakistani Food",
    grepl("Peruvian", data$category_tags) ~ "Latin American: Peruvian Food",  
    grepl("Polish", data$category_tags) ~ "European: Polish Food",
    grepl("Portuguese", data$category_tags) ~ "European: Portuguese Food",
    grepl("Russian", data$category_tags) ~ "European: Russian Food",
    grepl("Spanish", data$category_tags) | grepl("Tapas", data$category_tags) ~ "European: spanish Food",
    grepl("Thai", data$category_tags) ~ "Asian: Thai Food",
    grepl("Turkish", data$category_tags) ~ "Asian: Turkish Food",
    grepl("Vietnamese", data$category_tags) ~ "Asian: Vietnamese Food",
    
    grepl("Hawaiian", data$category_tags) ~ "Oceanian: Hawaiian Food",
    grepl("Guamanian", data$category_tags) ~ "Oceanian: Guamanian Food",
    
    # American Specific
    grepl("Cajun and Creole Food", data$category_tags) ~ "North American: Cajun and Creole Food",
    grepl("Southwestern Food", data$category_tags) ~ "North American: Southwestern Food",
    grepl("BBQ and Southern Food", data$category_tags) ~ "North American: BBQ and Southern Food",
    
    # Regions
    grepl("Polynesian", data$category_tags) ~ "Oceanian: Other Polynesian Food",
    grepl("Scandinavian", data$category_tags) ~ "European: Scandinavian Food",
    grepl("Caribbean", data$category_tags)  ~ "Latin American: Other Caribbean Food",
    # grepl("Middle Eastern", data$category_tags) ~ "Middle Eastern Food",
    # grepl("Mediterranean", data$category_tags) ~ "Mediterranean Food",
    
    # Larger Regions/Continents
    grepl("Latin American", data$category_tags) ~ "Latin American: Other",
    grepl("European", data$category_tags)  ~ "European: Other",
    grepl("Asian", data$category_tags) ~ "Asian: Other",
    grepl("African", data$category_tags) ~ "African: Other",
    
    TRUE ~ "North American: American Food"))
  
  ##### Method 3 #####
  # combine the two previous categorization methods
  data$combined <- paste(data$restaurant_region, data$restaurant_service, sep = '-')
  
  # frequency of categories
  x = sort(table(data$combined), decreasing = T)
  x <- as.data.frame(x)
  x$Var1 <- as.character(x$Var1)
  
  # Choose the top categories that constitute the top 90% market share
  
  count = 0
  categories_need <- c()
  
  for (i in 1:nrow(x)) {
    if (count < nrow(data) * 0.9) {
      count <- count + x[i,2]
      categories_need <- append(categories_need, x[i,1])
    }
  }
  
  
  # Replace the other remaining categories to "Other" using data.table (this is the fastest)
  setDT(data)
  data[!combined %in% categories_need, combined := "Other"]
  
  ##### Prepare for Calculating Diversity Score #####
  
  # Merge the long data with their restaurant categories
  data_long <- left_join(data_long, data %>% select('placekey', 'restaurant_service', 'restaurant_region', 'combined'), by = "placekey")
  
  # Aggregate
  service_type <- data_long %>%
    group_by(visitor_home_cbg, restaurant_service) %>%
    summarise(counts = sum(count, na.rm = TRUE))
  
  region_type <- data_long %>%
    group_by(visitor_home_cbg, restaurant_region) %>%
    summarise(counts = sum(count, na.rm = TRUE))
  
  combined_type <- data_long %>%
    group_by(visitor_home_cbg, combined) %>%
    summarise(counts = sum(count, na.rm = TRUE))
  
  # Set up the list for cencus cbg: the cbgs should be the same across three methods
  cbg_list <- unique(service_type$visitor_home_cbg)
  
  
  ##### Hill Numbers for Method 1 #####
  
  
  ### 1. q = 0 (Richness)
  
  calculate_q0 <- function(i) {
    
    temp <- service_type[service_type$visitor_home_cbg == i, ]
    
    length(unique(temp$restaurant_service))
  }
  
  m1q0 <- lapply(cbg_list, calculate_q0)
  m1q0 <- unlist(m1q0, use.names =  F)
  
  
  ### 2. q = 1 (Exponential of Shannon Diversity Index)
  
  calculate_q1 <- function(i) {
    
    temp <- service_type[service_type$visitor_home_cbg == i, ]
    
    total <- sum(temp[, 3])
    
    P <- temp[, 3] / total
    
    exp( -sum(P * log(P, base = exp(1)), na.rm = TRUE) )
    
  }
  
  m1q1 <- lapply(cbg_list, calculate_q1)
  m1q1 <- unlist(m1q1, use.names =  F)
  
  
  ### 3. q = 2 (Inverse of Simpson's Diversity Index)
  
  calculate_q2 <- function(i) {
    
    temp <- service_type[service_type$visitor_home_cbg == i, ]
    
    total <- sum(temp[, 3])
    
    P <- temp[, 3] / total
    
    1 / ( sum( P^2 ) )
    
  }
  
  m1q2 <- lapply(cbg_list, calculate_q2)
  m1q2 <- unlist(m1q2, use.names =  F)
  
  
  
  ##### Hill Numbers for Method 2 #####
  
  
  ### 1. q = 0 (Richness)
  
  calculate_q0 <- function(i) {
    
    temp <- region_type[region_type$visitor_home_cbg == i, ]
    
    length(unique(temp$restaurant_region))
  }
  
  m2q0 <- lapply(cbg_list, calculate_q0)
  m2q0 <- unlist(m2q0, use.names =  F)
  
  
  ### 2. q = 1 (Exponential of Shannon Diversity Index)
  
  calculate_q1 <- function(i) {
    
    temp <- region_type[region_type$visitor_home_cbg == i, ]
    
    total <- sum(temp[, 3])
    
    P <- temp[, 3] / total
    
    exp( -sum(P * log(P, base = exp(1)), na.rm = TRUE) )
    
  }
  
  m2q1 <- lapply(cbg_list, calculate_q1)
  m2q1 <- unlist(m2q1, use.names =  F)
  
  
  ### 3. q = 2 (Inverse of Simpson's Diversity Index)
  
  calculate_q2 <- function(i) {
    
    temp <- region_type[region_type$visitor_home_cbg == i, ]
    
    total <- sum(temp[, 3])
    
    P <- temp[, 3] / total
    
    1 / ( sum( P^2 ) )
    
  }
  m2q2 <- lapply(cbg_list, calculate_q2)
  m2q2 <- unlist(m2q2, use.names =  F)
  
  
  
  ##### Hill Numbers for Method 3 #####
  
  
  ### 1. q = 0 (Richness)
  
  calculate_q0 <- function(i) {
    
    temp <- combined_type[combined_type$visitor_home_cbg == i, ]
    
    length(unique(temp$combined))
  }
  
  m3q0 <- lapply(cbg_list, calculate_q0)
  m3q0 <- unlist(m3q0, use.names =  F)
  
  
  ### 2. q = 1 (Exponential of Shannon Diversity Index)
  
  calculate_q1 <- function(i) {
    
    temp <- combined_type[combined_type$visitor_home_cbg == i, ]
    
    total <- sum(temp[, 3])
    
    P <- temp[, 3] / total
    
    exp( -sum(P * log(P, base = exp(1)), na.rm = TRUE) )
    
  }
  
  m3q1 <- lapply(cbg_list, calculate_q1)
  m3q1 <- unlist(m3q1, use.names =  F)
  
  
  ### 3. q = 2 (Inverse of Simpson's Diversity Index)
  
  calculate_q2 <- function(i) {
    
    temp <- combined_type[combined_type$visitor_home_cbg == i, ]
    
    total <- sum(temp[, 3])
    
    P <- temp[, 3] / total
    
    1 / ( sum( P^2 ) )
    
  }
  
  m3q2 <- lapply(cbg_list, calculate_q2)
  m3q2 <- unlist(m3q2, use.names =  F)
  
  
  ##### Save as a dataframe #####
  cbg_diversity <- data.frame(cbg_list, m1q0, m1q1, m1q2, m2q0, m2q1, m2q2, m3q0, m3q1, m3q2)
  
  y <- substr(year_quarter[j], 1, 4)
  q <- substr(year_quarter[j], 5, 6)
  cbg_diversity$year <- y
  cbg_diversity$quarter <- q
  
  # Write to current working directory (user can change if desired)
  out_file <- paste0(y, "_", q, ".csv")
  write.csv(cbg_diversity, file = out_file, row.names = FALSE)
  cat("Saved:", out_file, "\n")
  
}

# record end time
end_time <- Sys.time()
cat("Total execution time:", end_time - start_time, "\n")

