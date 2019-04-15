# Exploratory Data Analysis of Medicare Excess Readmission Ratios

This project conducts a first pass exploratory data analysis (EDA) of excess readmission ratios from the Center for Medicare Services (CMS) Hospital Readmissions Reduction Program (HRRP). The analysis uses publicly available data to explore excess readmission ratios across conditions and hospital characteristics. 

The EDA results can be viewed in your browser [here](https://htmlpreview.github.io/?https://github.com/marisalyn/medicare_readmit/blob/master/EDA.html). 

## Overview of Files

Data is pulled from APIs, cleaned, and merged in the file `data_cleaning.R`. The exploratory analysis, including additional background information, key results, and possible next steps are in the file `EDA.Rmd` and the output of this file is viewable directly from the `EDA.html` file. Several simple user-defined functions used in the EDA are in the `functions.R` file.

## Running locally

#### Files
The only file that needs to be run to reproduce the results in `EDA.html` is `EDA.Rmd`. 

#### Packages 
This project uses [packrat](https://rstudio.github.io/packrat/), which helps manage package versions. All of the package .tar.gz files are included in the `packrat/src/` folder. This folder is quite large, but if you clone/download the project R you won’t have to download packages form external repositories in order to run the `EDA.Rmd` file. 

If you decide to download single files separately, the following packages are required: `plyr`, `tidy verse`, `RSocrata`, `kableExtra`,` reshape2`, and `stargazer`. 

Details of the required packages, dependencies, and versions can be located under `packrat/packrat.lock`. 
