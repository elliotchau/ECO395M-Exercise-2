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
PART 1

In determining what factors are the best predictors for cancer, and thus for doctors to look for when making their recall decision, or first goal was to check and see if any of the radiologists in the data set were perhaps more conservative than others when making their decision. If perhaps one doctor was more likely to recall a patient regardless of actual significant risk factors, it could bias the small data set we have towards one radiologist’s decisions. 

We began by looking at the raw percentage of recalls in the data set and noticed that only 14.99% of all patients are recalled. Due to such a low percentage of recall occurrences, recall can therefore be termed a “rare outcome”, making accurate predictions more difficult. Next we looked at the raw number of percentages of breast cancer outcomes in out data set and noticed that there only 37 of the 987 positive cancer outcomes in the data, meaning that only 3.74% of all patients actually have cancer.  Finally, we did the same process in order to view the raw number and percentage of patients who were seen by each radiologist in order to determine whether any one radiologist had seen a larger proportion of patients than others. Each of the 5 radiologists is associated with roughly 20% of the observations in the data set meaning that they each have a near equal weight on the total number of patients. 

Our next step was to create a table that compared each radiologist with the raw percentage of recall outcomes that they are associated with. From the raw data, it looks as though radiologist 89 and 66 have the highest proportion of recalls with 3.85% and 3.74%, respectively, of the total 15% of recalls that occur (or roughly 25.67% and 24.99% of the total number of recall outcomes. The lowest percentages of recall outcomes were those conducted by radiologist 34, whose recall decisions were only 1.77% of the original 15% (roughly 11.48% of the total recall outcomes). 

Although it is clear that some radiologists have much higher recall percentages than others, because this is only based on the raw data, we do not know whether some radiologists see a larger number of patients who, due to their specific risk factors, are at a greater risk for breast cancer. Therefore in order to find whether some of the radiologists are perhaps more clinically conservative than others, we must find the proportion of recalls associated with each radiologist while holding all patient risk factors fixed.

In order to do this, we created four generalized linear models to find out which radiologists have a higher recall rate, regardless of the set of patients that they have actually seen. The first model regresses cancer on recall in order to find what the odds are that someone is recalled given that they actually have cancer. This regression came back statistically significant, as one would hope, and it is clear that if a patient does have cancer, the chances that they are recalled by a doctor are incredibly high. However, due to the low percentage of recall outcomes, it has a very high deviance score. The next model regresses all variables in the data set on recall and also comes back with a high deviance score, however when looking at the odds rations for each radiologist, we can see that radiologists 66 and 89 are 1.49 and 1.61 times more likely to recall a patient than radiologist 13 who is the omitted category. It should also be noted that each radiologist did come back as statistically significant at a .05% level, and thus each radiologist individually affects a recall decision, and not just the patient risk factors. Our next model included and interaction between radiologist and cancer in order to control for cancers affect on recall in association with each radiologist. Something to note here is that radiologist34 actually came back as statistically significant on recall outcomes when the interaction variables were included even though the odds of them recalling a patient are only .053 times as likely to recall a patient as radiologist13 (compared to radiologist89 who is 1.5 times more likely to recall a patient than radiologist13).

From these models, we can see that even when we hold patient factors constant for all radiologists, radiologist89 and radiologist66 are more clinically conservative than their colleagues due to having much larger odds for recalling patients than radiologists 13, 34, and 95.

PART 2

One of the hardest things about making the decision to screen a patient or not is understanding which patient factors may put them at a higher risk for breast cancer. In order to find what factors could potentially be more correlated with cancer, and those that our sample of doctors used in their recall decisions, we partitioned the data into training and testing splits and ran a random forest regression focused on recursive feature elimination in order to find the best subset of features for both our recall variable and recall observations, and on our cancer variable, in order to find what variables might more accurately predict that a patient is at higher risk for cancer.

The reason for running this recursive feature elimination on the two separate outcomes is to see if there is a chance that doctors are focusing on the wrong, or lower correlation/accurate, variables when making their recall decisions. Additionally, due to the small sample size, and very low probability of both recall and cancer occurring, the recursive feature elimination randomly samples with replacement from this original data set in order to artificially increase our sample size so that we can attempt to find a more accurate prediction model. During this sampling process, it randomly selects different variables to use and holds on to the highest performing models before outputting the best predictive variables to be used in order to train a model to accurately predict the outcome variable based on cross validation. It is our hope that by doing this we can help doctors be more confident in their recall decision, and so that patients know whether they fall under a higher risk category or not.

We first began by removing all radiologists from the dataset. By doing so we are hoping to remove any impact that persona bias or conservatism regarding recall decisions based on each individual doctor from affecting the regression. Next, using recall as the out outcome variable, we found that doctors tend to base their recall decision most commonly on the following variables: cancer, premenopause, postmenoNoHT, and age groups for those between 50-59 and 70 plus. We then included these variables in another, more finely tuned, random forest, neural net, and generalized linear model, in order to test these variables predictive power under different models and situations.

The neural net and random forest models came back with the most accurate and significant of the three regressions. Both had an accuracy rating of roughly 86.02% and a Kappa rating of 16.97%, meaning that they are relatively useful and accurate for out of sample prediction. The GLM model returned a statistically significant accuracy rating of 85.21% and a 12.89% kappa rating. Each model came back with a high true positive rate and low false positive rate, and therefore we can assume that all of these variables are indeed good predictors of what doctors tend to look for when making their recall decision based on cross validation. 

Next we followed the same procedure and used cancer as the outcome variable. Using the recursive feature elimination, our model narrowed the important variables down to recall, density4, age 60-69, pre-menopause, and density3. This time the neural net returned a statistically significant accuracy rate of 96%, however it also had a kappa value of 0% and thus has no true out of sample predictive power. This is likely due to the very small number of cancer outcomes in the data set, and thus it did not obtain enough data to give back any truly useful information. The GLM model however returned a 96.15% accuracy rate that is statistically significant with a kappa rating of 12.59%, as well as a low false positive and a high positive prediction value. Therefore we can assume that the neural net model was likely heavily over fitted and therefore a simpler model is likely to give better results. 

Last, we used the recall predictors in a GLM model with cancer as the outcome variable in order to see if it could potentially give more accurate results than those from the original regression. This model did have a higher accuracy rating, however it has a kappa rating of 0% and thus is not useful for out of sample prediction. Although we are confident that doctors are not completely inaccurate in their decision for recalling, the reason such a low out of sample prediction rate occurred is likely due to the very small number of cancer outcomes in our sample size. 

Using the data that we have been given, and advanced statistical regression techniques, we believe that the models and variables that we have provided may be of some use for doctors who are concerned with whether they are paying attention to the right factors regarding their patients potential for testing positive for cancer during a mammogram screening, and whether they should make a recall decision. We still believe that it is worthwhile to take the variables that we have found through our regression into consideration, and hope that doing so will lead to less unnecessary recalls in the future, and more accurate cancer detection rates. 


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
