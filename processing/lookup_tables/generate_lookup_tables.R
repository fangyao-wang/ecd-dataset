
service_rules <- list(
  # Step 1: Distinct service formats
  list(1, "Fine Dining", "Fine Dining"),
  list(2, "Fast Food", "Fast Food"),
  list(2, "Drive Through", "Fast Food"),
  list(3, "Buffet", "Buffet"),
  list(3, "Cafeteria", "Buffet"),
  list(4, "Cafe", "Cafe"),
  list(4, "Coffee Shop", "Cafe"),
  list(5, "Casual Dining", "Casual Dining"),
  list(5, "Diner", "Casual Dining"),
  list(5, "Bistro", "Casual Dining"),
  list(6, "Bar or Pub", "Bar or Pub"),
  list(6, "Sports Bar", "Bar or Pub"),
  list(6, "Irish Pub", "Bar or Pub"),
  list(6, "Brewery or Brewpub", "Bar or Pub"),
  list(6, "Wine Bar", "Bar or Pub"),
  list(6, "Cocktail Lounge", "Bar or Pub"),
  list(6, "Beer Garden", "Bar or Pub"),
  list(6, "Dive Bar", "Bar or Pub"),
  # Step 2: Full‑Service Restaurants (from sub_category)
  list(7, "Full-Service Restaurants", "Casual Dining"),
  # Step 3: Additional operational formats
  list(8, "Snacks", "Snack"),
  list(8, "Dessert", "Snack"),
  list(8, "Ice Cream Shop", "Snack"),
  list(8, "Gelato Shop", "Snack"),
  list(8, "Bakery", "Snack"),
  list(9, "Counter Service", "Fast-casual"),
  list(9, "Hot Dogs", "Fast-casual"),
  list(9, "Donut Shop", "Fast-casual"),
  list(9, "Chicken Wings", "Fast-casual"),
  list(9, "Burgers", "Fast-casual"),
  list(9, "Sandwich Shop", "Fast-casual"),
  list(9, "Bagel Shop", "Fast-casual"),
  list(9, "Salad", "Fast-casual"),
  list(9, "Deli", "Fast-casual"),
  list(10, "Truck or Cart", "Food Truck"),
  list(11, "Bubble Tea Shop", "Specialty Drinks/Tea"),
  list(11, "Smoothie & Juice Bar", "Specialty Drinks/Tea"),
  list(11, "Beverages", "Specialty Drinks/Tea"),
  list(11, "Tea House", "Specialty Drinks/Tea"),
  # Step 4: Residual (default)
  list(12, NA, "Other")   # No pattern, catch‑all
)

# Convert to data frame
service_df <- do.call(rbind, lapply(service_rules, function(x) {
  data.frame(priority = x[[1]], pattern = x[[2]], category = x[[3]], 
             stringsAsFactors = FALSE)
}))

# Write CSV
write.csv(service_df, "service_lookup.csv", row.names = FALSE)

# ------------------------
# 2. Ethnic Cuisine Lookup
# ------------------------

# Patterns in priority order (country‑specific first, then regional, then default)
ethnic_rules <- list(
  # Country‑level (order as in your case_when)
  list(1, "Argentinan", "Latin American: Argentinan Food"),
  list(1, "Australian", "Oceanian: Australian Food"),
  list(1, "Austrian", "European: Austrian Food"),
  list(1, "Brazilian", "Latin American: Brazilian Food"),
  list(1, "Burmese", "Asian: Burmese Food"),
  list(1, "Canadian", "North American: Canadian Food"),
  list(1, "Chinese", "Asian: Chinese Food"),
  list(1, "Cuban", "Latin American: Cuban Food"),
  list(1, "Ethiopian", "African: Ethiopian Food"),
  list(1, "Filipino", "Asian: Filipino Food"),
  list(1, "French", "European: French Food"),
  list(1, "Creperie", "European: French Food"),
  list(1, "Rotisserie", "European: French Food"),
  list(1, "German", "European: German Food"),
  list(1, "Greek", "European: Greek Food"),
  list(1, "Hungarian", "European: Hungarian Food"),
  list(1, "Indian", "Asian: Indian Food"),
  list(1, "Irish", "European: Irish or British Food"),
  list(1, "Fish & Chips", "European: Irish or British Food"),
  list(1, "Irish Pub", "European: Irish or British Food"),
  list(1, "Italian", "European: Italian Food"),
  list(1, "Pizza", "European: Italian Food"),
  list(1, "Japanese", "Asian: Japanese Food"),
  list(1, "Sushi", "Asian: Japanese Food"),
  list(1, "Korean", "Asian: Korean Food"),
  list(1, "Lebanese", "Asian: Lebanese Food"),
  list(1, "Mexican", "Latin American: Mexican Food"),
  list(1, "Mongolian", "Asian: Mongolian Food"),
  list(1, "Moroccan", "African: Moroccan Food"),
  list(1, "Pakistani", "Asian: Pakistani Food"),
  list(1, "Peruvian", "Latin American: Peruvian Food"),
  list(1, "Polish", "European: Polish Food"),
  list(1, "Portuguese", "European: Portuguese Food"),
  list(1, "Russian", "European: Russian Food"),
  list(1, "Spanish", "European: spanish Food"),
  list(1, "Tapas", "European: spanish Food"),
  list(1, "Thai", "Asian: Thai Food"),
  list(1, "Turkish", "Asian: Turkish Food"),
  list(1, "Vietnamese", "Asian: Vietnamese Food"),
  list(1, "Hawaiian", "Oceanian: Hawaiian Food"),
  list(1, "Guamanian", "Oceanian: Guamanian Food"),
  # American regional (priority 2)
  list(2, "Cajun and Creole Food", "North American: Cajun and Creole Food"),
  list(2, "Southwestern Food", "North American: Southwestern Food"),
  list(2, "BBQ and Southern Food", "North American: BBQ and Southern Food"),
  # Broader regional (priority 3)
  list(3, "Polynesian", "Oceanian: Other Polynesian Food"),
  list(3, "Scandinavian", "European: Scandinavian Food"),
  list(3, "Caribbean", "Latin American: Other Caribbean Food"),
  # Continental (priority 4)
  list(4, "Latin American", "Latin American: Other"),
  list(4, "European", "European: Other"),
  list(4, "Asian", "Asian: Other"),
  list(4, "African", "African: Other"),
  # Default (priority 5)
  list(5, NA, "North American: American Food")
)

ethnic_df <- do.call(rbind, lapply(ethnic_rules, function(x) {
  data.frame(priority = x[[1]], pattern = x[[2]], category = x[[3]], 
             stringsAsFactors = FALSE)
}))

write.csv(ethnic_df, "ethnic_lookup.csv", row.names = FALSE)


