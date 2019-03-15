Exercise 2
===============
By Hana Krijestorac, David Garrett, and Elliot Chau

Problem 1
================
Taxing Authority of Saratoga, NY
----------------

Many of the town’s local services such as our local schools, public libraries, and emergency services are funded through property taxes. In order to determine the appropriate amount of tax to levy every year, we need to determine the value of houses as well as the property that it occupies.


In order to assess property values, we used several models that included different components and house characteristics.


The following is the set of characteristics along with descriptions:

	lotSize: the amount of land occupied by the property (in acres)
	landValue: the intrinsic value of just the land itself (in dollars)
	waterfrontDummy: determines if the house is set by a waterfront
	centralAirDummy: determines if heating and cooling is delivered centrally
	newConstructionDummy: determines if the house was newly built
	age: the age of the house (in years)
	ageSq: the possibility of changing price behavior of age as it increases
	bedrooms: the number of bedrooms in the house
	bathrooms: the number of bathrooms in the house
	heating: how the house the heated; electric, hot water/steam, or hot air
	livingArea: the amount of usable space in the house (in square feet)
	pctCollege: the percentage of adults in the neighborhood that have a college degree
	valueSqFt: landValue/livingArea to compute an intrinsic $/sq ft assessment


We evaluate some of these characteristics together -- i.e. we see what effects some of the terms have on each other. For example, having more bathrooms relative to the number of rooms in the house increases the home's valuation with increased convenience and more complex infrastructure. Some noted features that increase house values include lot size, square footage, and properties on a waterfront. 


In order to predict the value of your house, we evaluated two different styles of models:

	(1)	An independent model using a combination of the characteristics listed above (just to be clear: linear model).
	(2)	The mean price of houses with similar characteristics (just to be clear: KNN). 

Calculations were performed to determine how accurate our models were in predicting house values. Because these models are projections, each method carries a certain amount of error in its measurement. Our objective is to minimize this error. In doing so, we computed errors from Model 1 and errors from eight similar houses in Model 2. We found that Model 1 carried a lower error. This indicates that Model 1 is a better assessment of property values so that property taxes are computed more accurately.


![rmseGrid](https://user-images.githubusercontent.com/47119252/54454908-8bba0a00-4728-11e9-8bec-443216f201e5.png)

Problem 2
================
Hospital audit
----------------


Problem 3
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

Based on these results, we conclude that there is a tradeoff between the overall error rate and the individual rates of correct identification. Regressing first leads to lower overall error but higher accuracy for true/false positives. If thresholding first, the results are the opposite. It depends on what metric the predictor wants to optimize.

The predicted error rate of just over 40% is a bit more than an advantageous coin flip. It is difficult to predict which articles go viral due to the dynamic nature of internet culture and dynamic contemporary events. In addition, it is also difficult to determine how compelling the article is in order to motivate people to share it.
