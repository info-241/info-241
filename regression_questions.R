library(data.table)
library(magrittr)

## Question 1:
##
## What is the distribution of p-values if there is no relationship between
## a LHS and RHS variable in a regression?

## Question 2:
##
## If you test 20 variables none of which _actually_ have a relationship with
## the outcome, what are the chances that you do *not* reject the null
## hypothesis on any of the variables?


0.95^20

## Question 3:
##
## How does using an F-test, rather than simply many hypothesis tests help
## to avoid the false-discovery of what seem to be significant relationships?


make_data <- function(size_of_data = 1000) {
  d <- data.frame(
    id  = 1:size_of_data,
    x1  = runif(n = size_of_data, min = 0, max = 1),
    x2  = runif(n = size_of_data, min = 0, max = 1),
    x3  = runif(n = size_of_data, min = 0, max = 1),
    x4  = runif(n = size_of_data, min = 0, max = 1),
    x5  = runif(n = size_of_data, min = 0, max = 1),
    x6  = runif(n = size_of_data, min = 0, max = 1),
    x7  = runif(n = size_of_data, min = 0, max = 1),
    x8  = runif(n = size_of_data, min = 0, max = 1),
    x9  = runif(n = size_of_data, min = 0, max = 1),
    x10 = runif(n = size_of_data, min = 0, max = 1),
    x11 = runif(n = size_of_data, min = 0, max = 1),
    x12 = runif(n = size_of_data, min = 0, max = 1),
    x13 = runif(n = size_of_data, min = 0, max = 1),
    x14 = runif(n = size_of_data, min = 0, max = 1),
    x15 = runif(n = size_of_data, min = 0, max = 1),
    x16 = runif(n = size_of_data, min = 0, max = 1),
    x17 = runif(n = size_of_data, min = 0, max = 1),
    x18 = runif(n = size_of_data, min = 0, max = 1),
    x19 = runif(n = size_of_data, min = 0, max = 1),
    x20 = runif(n = size_of_data, min = 0, max = 1)
  )
  
  ## Question 3a:
  ##
  ## - What is happening in the code above?
  ## - What is the specified covariance between the x-variables?
  ## - What is happening in the code below? What is the relationship between
  ##     the x-variables and the y-variable?
  
  d$y <- 0 + rnorm(n = size_of_data, mean = 0, sd = 3)
  
  return(d)
}

d <- make_data(size_of_data = 1000)

test_data <- function(d) {
  ## Question 3b:
  ##
  ## - What is happening on the line below? You might look into the
  ##     documentation for `lm`, or you might look at the resulting object
  ##     that is created to try and learn what is happening.
  
  model <- lm(y ~ ., data = d)
  
  return(model)
}

test_data(make_data(1000))

extract_tests <- function(model) {
  ## Question 3c:
  ##
  ## - What is happening on this next line? What is in the 4th column of this
  ##     summary object?
  ## - Is it a risky programming choice to make to code this specifically to
  ##     the 4th column? Why or why not? What are the alternatives that you
  ##     might propose? If you're so inclined, you can make the change to
  ##     reduce your risk.
  
  any_coefficients_reject <- any(summary(model)$coefficients[, 4] < 0.05)
  
  ## Question 3d:
  ##
  ## Why is the f-test p-value compuated as 1 - pf?
  
  f_test_reject <- 1 - pf(
    q = summary(model)$fstatistic["value"],
    df1 = summary(model)$fstatistic["numdf"],
    df2 = summary(model)$fstatistic["dendf"]) < 0.05
  
  ## In this line, you are creating a data.table with two variables and one
  ## observation each. This is a convienience method because there is a
  ## neat method called `rbindlist` that makes it possible to join a large
  ## number of data.tables efficiently. `
  
  return(
    data.table(
      any_coef_reject = any_coefficients_reject,
      f_test_reject   = f_test_reject
    )
  )
}

## Question 4:
##
## - Before running the next line, what do you expect that you will see?
## - What will be the shape of what is returned to you? And, what are the
##     possible values that could be obtained?

make_data(size_of_data = 2000)

## Question 5:
##
## - Before running the next lines, what do you expect you will see?

make_data() %>%
  test_data %>%
  extract_tests


simulation_result <- rbindlist(
  replicate(
    n = 1000,
    expr =
      make_data(size_of_data = 100) %>%
      test_data %>%
      extract_tests,
    simplify = FALSE)
)


## Question 5:
##
## - What do you observe about the t-tests? What rate do they false reject at?
## - What do you observe about the f-tests? What rate do they false reject at?
## - Is this a problem that goes away with data? Increase the size of the
##     sample that you're using by changing the `size_of_data` parameter.
##     Does this affect the false rejection on either of the f-test or the
##     t-test?

simulation_result[, proportions(
  table("any" = any_coef_reject, "f-test" = f_test_reject)), 
]
