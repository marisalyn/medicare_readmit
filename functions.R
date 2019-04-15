readmit_stats <- function(dataframe, hospital_characteristic) {
  # calculate excess readmission ratio mean, median, sd, and count 
  # for a dataframe, grouped hospital_characteristic
  
  table1 <- dataframe %>% 
    select(c(readm_ratio, !!hospital_characteristic)) %>%
    group_by(!!hospital_characteristic) %>% 
    summarise_all(c("mean", "median", "sd"), na.rm = TRUE) 
  
  table2 <- dataframe %>% 
    select(c(readm_ratio, !!hospital_characteristic)) %>%
    group_by(!!hospital_characteristic) %>% 
    count() 
  
  table <- reduce(list(table1, table2), left_join) %>%
    kable %>% 
    kable_styling(bootstrap_options = c("striped", "hover"))
  
  return(table)
} 

readmit_boxplot <- function(dataframe, hospital_characteristic) {
  # display boxplot of excess readmission ratio 
  # for a dataframe, grouped hospital_characteristic
  
  ggplot(dataframe) + 
    theme(axis.text.x = element_blank()) + 
    ylab("Excess Readmission Ratio") + 
    geom_boxplot(
      aes_string(x = hospital_characteristic, y = "readm_ratio",
                 group = hospital_characteristic, 
                 fill = hospital_characteristic
      )) 
}


readmit_density <- function(dataframe, hospital_characteristic) {
  # display density plot of excess readmission ratio 
  # for a dataframe, grouped hospital_characteristic
  
  ggplot(dataframe) + 
    ylab("Excess Readmission Ratio") + 
    geom_density(
      aes_string("readm_ratio",
                 group = hospital_characteristic, 
                 color = hospital_characteristic
      )) 
}

get_upper_tri <- function(cormat){
  # used to get upper triangle of correlation matrix
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}

readmit_emergency_services_ttest <- function(dataframe) {
  # calculate a t-test for excess readmission ratio by emergency_services
  # for a given dataframe
  
  emergency_services <- dataframe %>% 
    filter(emergency_services == TRUE) %>% 
    select(readm_ratio)
  
  no_emergency_services <- dataframe %>% 
    filter(emergency_services == FALSE) %>% 
    select(readm_ratio)
  
  return(t.test(emergency_services, no_emergency_services))
}

readmit_state_plot <- function(dataframe) {
  # plot excess readmission ratio mean and SD by state for a given dataframe
  
  ggplot(dataframe,
         aes(x = readm_ratio_avg,
             y = reorder(state, readm_ratio_avg), 
             color = cut(hospital_rating_mean, c(0,1,2,3,4,5)))) + 
    scale_fill_brewer( type = "seq", palette = "Blues") +
    labs(color = "Overall Hospital Rating\n") +
    geom_vline(xintercept = 1, color = "gray30") +
    geom_point(size = 2)  +
    geom_errorbarh(aes(xmin = readm_ratio_avg - readm_ratio_sd, 
                       xmax = readm_ratio_avg + readm_ratio_sd,
                       width=.2)) + 
    ylab("State") + 
    xlab("Excess Readmission Ratio") +
    ggtitle("Average Excess Readmission Ratio, plus/minus 1 SD")
}