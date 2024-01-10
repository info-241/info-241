Cluster and Robust
================
Alex

# Theory

How should one estimate robust and clustered variance covariance
matrices?

We talk about assumptions for regression. These assumptions are the
Gauss-Markov set of assumptions, but boil down to:

1.  We have written down the right model;
2.  The data iid;
3.  The variance of the data is finite, and constant.

In this little demo, we’re really just talking about the last of these.
In practice, especially with regression analysis of experiments, but
also more broadly, we often either don’t have strong theoretical reasons
to expect the variance in our residuals (the squared deviations from the
regression line) to be constant at all points in the distribution. At
least, I don’t have strong priors for most types of data; which makes me
think that you probably shouldn’t either.

Think about what such a strong prior would mean! You would have to:

1.  Have a mental model of the data generating process;
2.  Have a mental model of the best fitting linear trend about that DGP;
3.  Know that there is no difference in the performance of the model at
    different points in the model. That’s deep.

Here’s the process when we’re thinking about Standard Errors, and
getting them right.

1.  Estimate your linear model. Whether this is gaussian (OLS), binomial
    (logit,probit), counting (Poisson), time to failure (exponential),
    or some other more esoteric form *IT DOESN’T MATTER* – the
    estimation of coefficients is a distinct task from getting the
    uncertainty about those estimates correct.
2.  Think about the data generating process. Does the assignment to
    treatment have any clustering to it? If not, then estimate robust
    standard errors. If yes, then estimate cluster-robust standard
    errors. Do the outcomes have some clustering to them? Are there
    groupings in the data? Then you should probably include a
    fixed-effect for each group, and also estimate cluster-robust
    standard errors.
3.  The estimation process is straightforward.

-   Load Packages
    -   For both: load the `lmtest` package for easy testing.
    -   For both: load the `sandwich` package for estimating robust SEs
    -   For clustering: load the additional package `multiwayvcov`
-   Compute Appropriate VCOV
    -   robust : `vcovHC`
    -   cluster: `vcovCL`

# Demos

``` r
library(lmtest)
library(sandwich)
library(data.table)
library(stargazer)
```

Begin by loading the sample data

``` r
rm(list = ls())
d <- fread(
  'https://www.kellogg.northwestern.edu/faculty/petersen/htm/papers/se/test_data.txt', 
  col.names = c('firmid', 'year', 'x', 'y'))
```

This data is simulated data with 500 firms identified over 10 separate
years.

-   `firmid`: the firm identifier
-   `year` : the year, ordered from 1-10
-   `x` : the RHS variable
-   `y` : the LHS variable

``` r
head(d)
```

    ##    firmid year          x          y
    ## 1:      1    1 -1.1139730  2.2515350
    ## 2:      1    2 -0.0808538  1.2423460
    ## 3:      1    3 -0.2376072 -1.4263760
    ## 4:      1    4 -0.1524857 -1.1093940
    ## 5:      1    5 -0.0014262  0.9146864
    ## 6:      1    6 -1.2127370 -1.4246860

## Estimate Coefficients

Now, we can *really* easily fit a model for this.

``` r
m1 <- d[ , lm(y ~ x)]
```

## Estimate Uncertainty

Robust standard errors are calculated using the `sandwich` package, and
via the `vcovHC` function call, which is the **V**ariance **CoV**ariance
estimator that is **H**eteroskedastic **C**onsistent .

``` r
## ? vcovHC
m1$vcovHC_ <- vcovHC(m1)
coeftest(m1, vcov. = m1$vcovHC_)
```

    ## 
    ## t test of coefficients:
    ## 
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) 0.029680   0.028366  1.0463   0.2955    
    ## x           1.034833   0.028412 36.4223   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

``` r
stargazer(
  m1, 
  type = 'text',
  se=list(sqrt(diag(m1$vcovHC_))), 
  header=F
  )
```

    ## 
    ## ===============================================
    ##                         Dependent variable:    
    ##                     ---------------------------
    ##                                  y             
    ## -----------------------------------------------
    ## x                            1.035***          
    ##                               (0.028)          
    ##                                                
    ## Constant                       0.030           
    ##                               (0.028)          
    ##                                                
    ## -----------------------------------------------
    ## Observations                   5,000           
    ## R2                             0.208           
    ## Adjusted R2                    0.208           
    ## Residual Std. Error      2.005 (df = 4998)     
    ## F Statistic         1,310.740*** (df = 1; 4998)
    ## ===============================================
    ## Note:               *p<0.1; **p<0.05; ***p<0.01

Clustered standard errors are not much more difficult. They are, by
their nature, not only estimating the quantity of the covariance within
the cluster, but are also estimating robust estimates as well.

``` r
## 
## sandwich::vcovCL
## 

## one way clustering 
m1$vcovCL1_ <- vcovCL(m1, cluster = d[ , firmid])
## two way clustering
m1$vcovCL2_ <- vcovCL(m1, cluster = d[ , .(firmid, year)])

coeftest(m1, m1$vcovCL1_)
```

    ## 
    ## t test of coefficients:
    ## 
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) 0.029680   0.067013  0.4429   0.6579    
    ## x           1.034833   0.050596 20.4530   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

``` r
coeftest(m1, m1$vcovCL2_)
```

    ## 
    ## t test of coefficients:
    ## 
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) 0.029680   0.065064  0.4562   0.6483    
    ## x           1.034833   0.053558 19.3217   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

``` r
stargazer(m1, m1, 
          type = 'text', 
          se = list(sqrt(diag(m1$vcovCL1_)), 
                    sqrt(diag(m1$vcovCL2_)) ), 
          header=F
) 
```

============================================================ Dependent
variable:  
—————————- y  
(1) (2)  
———————————————————— x 1.035\*\*\* 1.035\*\*\*  
(0.051) (0.054)

Constant 0.030 0.030  
(0.067) (0.065)

------------------------------------------------------------------------

Observations 5,000 5,000  
R2 0.208 0.208  
Adjusted R2 0.208 0.208  
Residual Std. Error (df = 4998) 2.005 2.005  
F Statistic (df = 1; 4998) 1,310.740\*\*\* 1,310.740\*\*\*
============================================================ Note:
*p\<0.1; **p\<0.05; ***p\<0.01

To pull off the SEs from the Variance Covaraince matrix, we need only to
pull the squareroot of the diagonals of the VCOV.

``` r
m1$robust.se <-  sqrt(diag(m1$vcovHC_))  # note that this is operating on the
                                        # object we already created
m1$cluster1.se <- sqrt(diag(m1$vcovCL1_))
m1$cluster2.se <- sqrt(diag(m1$vcovCL2_))

## for comparison, let's compute the OLS SEs
m1$vcovCONSTANT_ <- vcovHC(m1, "const")
m1$seCONSTANT_   <- sqrt(diag(m1$vcovCONSTANT_))
```

With each of these esimated, we can produce a table that reports all the
estimates.

``` r
stargazer(m1, m1, m1, m1,
          type = 'text', 
          se = list(m1$seCONSTANT_, 
                    m1$robust.se,
                    m1$cluster1.se, 
                    m1$cluster2.se),
          add.lines = list(
            c('SE Flavor', 'OLS', 'Robust', 'Cl: firmid', 'Cl: firmid and year')
          ),
          header=F)
```

    ## 
    ## ==========================================================================================
    ##                                                    Dependent variable:                    
    ##                                 ----------------------------------------------------------
    ##                                                             y                             
    ##                                     (1)          (2)          (3)              (4)        
    ## ------------------------------------------------------------------------------------------
    ## x                                 1.035***     1.035***     1.035***        1.035***      
    ##                                   (0.029)      (0.028)      (0.051)          (0.054)      
    ##                                                                                           
    ## Constant                           0.030        0.030        0.030            0.030       
    ##                                   (0.028)      (0.028)      (0.067)          (0.065)      
    ##                                                                                           
    ## ------------------------------------------------------------------------------------------
    ## SE Flavor                           OLS         Robust     Cl: firmid  Cl: firmid and year
    ## Observations                       5,000        5,000        5,000            5,000       
    ## R2                                 0.208        0.208        0.208            0.208       
    ## Adjusted R2                        0.208        0.208        0.208            0.208       
    ## Residual Std. Error (df = 4998)    2.005        2.005        2.005            2.005       
    ## F Statistic (df = 1; 4998)      1,310.740*** 1,310.740*** 1,310.740***    1,310.740***    
    ## ==========================================================================================
    ## Note:                                                          *p<0.1; **p<0.05; ***p<0.01
