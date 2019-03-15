Exercise 2, Problem 3
================
Predicting when articles go viral
----------------
Regressing first and thresholding second.

The confusion matrix that indicates a 42.7% error rate.

    ##    yhat
    ## y      0    1
    ##   0 3735  342
    ##   1 3046  806

    ## [1] 0.4272922

The true positive rate correctly predicts viral articles that actually go viral 20.9% of the time.

``` r
806/(806+3046) #(1,1)/[(1,1)+(0,1)]
```

    ## [1] 0.209242

The false positive rate predicts articles will go viral but do not actually go viral 8.1% of the time.

``` r
342/(342+3735 #(1,0)/[(1,0)+(0,0)]
```

    ## [1] 0.08152174

The null model's performance.

    ## [1] 0.5065584

Thresholding first and regressing second.
The confusion matrix that indicates a 43.4% error rate.

    ##    yhat
    ## y      0    1
    ##   0 3686  340
    ##   1 3102  801

    ## [1] 0.4341027

The true positive rate correctly predicts viral articles that actually go viral 21.6% of the time under this method.

``` r
834/(834+3026) #(1,1)/[(1,1)+(0,1)]
```

    ## [1] 0.2160622

The false positive rate predicts articles will go viral but do not actually go viral 8.4% of the time.

``` r
344/(344+3725) #(1,0)/[(1,0)+(0,0)]
```

    ## [1] 0.08454166

The null model's performance.

    ## [1] 0.5065584

Based on these results, we conclude that there is a tradeoff between the overall error rate and the individual rates of correct identification. Regressing first leads to lower overall error but higher accuracy for true/false positives. If thresholding first, the results are the opposite. 
