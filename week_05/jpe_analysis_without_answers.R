## META DATA
##
## apfschoolcode is a code that indicates a school; we won't use it this week
## y1_nts:          the outcome of interest
## incentive:       treatment indicator
## pretest:         informative pretest value
## parent_literacy: less informative pretest value 

rm(list = ls())

## load packages
library(foreign)                        # for reading in strange file types
library(data.table)                     # another popular pacakge is haven. 
library(stargazer)

path <- "~/MIDS/w241/w241/week_05/"
file <- "week5indiaTeachers.dta"

load_and_clean_data <- function(path, file) { 
  
  d <- read.dta(paste0(path, file) )
  d <- data.table(d)
  
  ## How many rows exist when we read? 
  nrows_at_read <- nrow(d)
  cat(sprintf('There are %.f rows when we read the data. \n', nrows_at_read))
  
  ## let's keep only the parts of the data that have all measurements we need.
  d <- d[pretest_miss==0 & parent_miss==0]
  
  nrows_after_dropping <- nrow(d)
  
  cat(sprintf('There are %.f rows when we drop data we dont want.\n', nrows_after_dropping))
  cat(sprintf('So, we have lost %.f percent by dropping.\n', 100*(nrows_at_read-nrows_after_dropping) / nrows_at_read))
  
  return(d)
  }

d <- load_and_clean_data(path = path, file = file)

## 
## estimate the ATE
## 

ate <- 'fill this in'

##
## how likely is that to occur by chance?
## use RI
##

randomization_inference <- function(data, outcome_variable, treatment_indicator) { 
  ## it is a strange idiom of the language; but, you have to use `get()` within
  ## a function if you want to access a variable by name. 
  ## so, something like: data[ , get(outcome_variable)]
  
  }

ri_results <- replicate(
  n = 1000, 
  expr = randomization_inference(
    ata = d, 
    outcome_variable = y1_nts, 
    treatment_indicator = incentive
    ) 
) 

mean(ri_results > ate)

ate_plot <- ggplot() + 
  aes(x = ri_results) + 
  geom_histogram(bins = 30) + 
  geom_vline(xintercept = ate) + 
  labs(
    title = 'Distribution of ATEs Under Sharp Null',
    x = 'Randomization Inference ATEs'
  )

ate_plot
  
##
## What happens if we rescale the outcome to be the difference between 
##

d <- load_and_clean_data(path=path, file=file)

## create a new variable called y_rescaled that is the difference
## between the outcome we're interested in and the the pretest value.
## note that this is a strong functional form assumption for to calculate
## what is basically the "sharp difference" for each individual.

d[ , y_rescaled := 'YOU SHOULD CHANGE THIS LINE']

##
## What is the ATE of this rescaled value? 
## 

ate_rescaled <- 'fill this in'

ri_results_rescaled <- replicate(
  n = 1000, randomization_inference(
    data = 'fill this in', 
    outcome_variable = 'fill this in',
    treatment_indicator = 'fill this in'
    )
  ) 

mean(ri_results_rescaled > ate_rescaled)

## plot a histogram of this 
## you can reuse code from earlier.

##
## can we do it with regresion?
##

d <- read.dta(paste0(mypath, file))
d <- data.table(d)

## let's keep only the parts of the data that have all measurements we need.
d <- d[pretest_miss==0 & parent_miss==0]
nrow(d)

m1 <- lm( ) # only include the treatment factor 
m2 <- lm( ) # include the treatment and pre-test scores 

stargazer(m1, m2, type = "text")
