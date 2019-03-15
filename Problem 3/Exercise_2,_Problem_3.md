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

The true positive rate that correctly predicts viral articles that actually go viral.

``` r
806/(806+3046) #(1,1)/[(1,1)+(0,1)]
```

    ## [1] 0.209242

The false positive rate that predicts articles will go viral but do not actually go viral.

``` r
342/(3735+342) #(1,0)/[(1,0)+(0,0)]
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

The true positive rate that correctly predicts viral articles that actually go viral.

``` r
834/(834+3026) #(1,1)/[(1,1)+(0,1)]
```

    ## [1] 0.2160622

The false positive rate that predicts articles will go viral but do not actually go viral.

``` r
344/(344+3725) #(1,0)/[(1,0)+(0,0)]
```

    ## [1] 0.08454166

The null model's performance.

    ## [1] 0.5065584
