# This file includes 3 code chunks for (1) sourcing, (2) cleaning, and 
# (3) merging datasets on the Medicacre Hospital Readmissions Reduction 
# Program (HRRP) and Medicare data on General Hospital Information (GHI). 

# The data is sourced using the APIs for the relevant datasets. 

# The following libraries are required: plyr, tidyverse, and RSocrata
# library(plyr)
# library(tidyverse)
# library(RSocrata)

# ---- get_data ----

# load data from medicare on general hospital information
ghi <- read.socrata("https://data.medicare.gov/resource/rbry-mqwu.json")
# Note this dataframe has 34 variables but the website states there are 29.
# This discrepancy is because the "location" variable is broken out into 
# 6 different variables (address, city, state, zip, coordinates, and type)

# load data from medicare on hospital readmissions
hrrp <- read.socrata("https://data.medicare.gov/resource/kac9-a9fp.json")

# ---- clean_data ----

# separate location coordinates into two columns, longitude and latitude
ghi <- ghi %>%
  mutate(location.coordinates = map(location.coordinates, toString)) %>%
  separate(
    location.coordinates,
    into = c("long", "lat"),
    sep = ", ",
    convert = TRUE
  )

# replace "Not Available" text to NA in both datasets
hrrp <- hrrp %>% mutate_all(list(~replace(., . == "Not Available", NA)))
ghi <- ghi %>% mutate_all(list(~replace(., . == "Not Available", NA)))

# clean up classes
# make all but location coordinates into factor in general information dataframe 
cols2factor <- c(
  "county_name",
  "effectiveness_of_care_national_comparison",
  "effectiveness_of_care_national_comparison_footnote",
  "efficient_use_of_medical_imaging_national_comparison",
  "efficient_use_of_medical_imaging_national_comparison_footnote",
  "emergency_services",
  "hospital_name",
  "hospital_overall_rating",
  "hospital_overall_rating_footnote",
  "hospital_ownership",
  "hospital_type",
  "location_address",
  "location_city",
  "location_state",
  "location_zip",
  "meets_criteria_for_meaningful_use_of_ehrs",
  "mortality_national_comparison",
  "mortality_national_comparison_footnote",
  "patient_experience_national_comparison",
  "patient_experience_national_comparison_footnote",
  "provider_id",
  "readmission_national_comparison",
  "readmission_national_comparison_footnote",
  "safety_of_care_national_comparison",
  "safety_of_care_national_comparison_footnote",
  "timeliness_of_care_national_comparison",
  "timeliness_of_care_national_comparison_footnote"
)    

ghi[cols2factor] <- lapply(ghi[cols2factor], as.factor)

# make columns factor or numeric in hrrp dataframe
cols2factor <- c(
  "hospital_name",
  "measure_id",
  "provider_id", 
  "state", 
  "footnote"
) 

cols2numeric <- c(
  "expected", 
  "number_of_discharges", 
  "number_of_readmissions", 
  "predicted", 
  "readm_ratio"
)

hrrp[cols2factor] <- lapply(hrrp[cols2factor], as.factor)
hrrp[cols2numeric] <- lapply(hrrp[cols2numeric], as.numeric)

remove(cols2factor)
remove(cols2numeric)

# adjust measure ID
hrrp$measure_id <- sub(".*30-(.*?)-HRRP.*","\\1", hrrp$measure_id)

# ---- merge_data ----

# Figure out the unique keys... 
# GHI is uniquely identified with hospital name and provider ID
# Note that ccording to CMS documentation, provider ID is a combination of state 
# and facility type: 
# https://www.cms.gov/regulations-and-guidance/guidance/transmittals/downloads/r29soma.pdf
dim(unique(ghi[c("hospital_name", "provider_id")])) 

# HRRP is uniquely identified with hospital name, measure, & provider ID
dim(unique(hrrp[c("hospital_name", "measure_id", "provider_id")]))

# merge data: match by all common column names
# this is a many:1 merge 
# I use an inner join because there are some facilities in the HRRP data that
# do not have matching data in GHI
# Specifically, there are 1224 records from 185 hospitals
# For EDA purposes, I'll ignore these, but for a full analysis I would want to 
# explore this further
dat <- join(
  hrrp,
  ghi,
  by = intersect(names(hrrp), names(ghi)),
  type = "inner",
  match = "all"
)
