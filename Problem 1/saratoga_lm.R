library(tidyverse)
library(mosaic)
data(SaratogaHouses)
summary(SaratogaHouses)

###### PART 1 ######
  ###Build a better model than "lm_medium" in the start script
  ###Any particularly strong drivers of house price?

# Compare out-of-sample predictive performance
#### Create some new variables to include in the model
  #intrinsic land value to size of living area ($/sq ft)
SaratogaHouses$valueSqFt <- SaratogaHouses$landValue/SaratogaHouses$livingArea
  # age squared; older houses significantly drop in value
SaratogaHouses$ageSq <- SaratogaHouses$age*SaratogaHouses$age

# Split into training and testing sets
n = nrow(SaratogaHouses)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
saratoga_train = SaratogaHouses[train_cases,]
saratoga_test = SaratogaHouses[test_cases,]

# Fit to the training data
# The baseline model
lm1 = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
     fireplaces + bathrooms + rooms + heating + fuel + centralAir, data=SaratogaHouses)

# Adding land value and interactions with rooms and bedrooms (from class)
  # The logic is that bathrooms should match bedrooms so you don't have to wait forever
  # Also heated rooms 
lm2 = lm(price ~ lotSize + landValue + waterfront + newConstruction + bedrooms*bathrooms + heating 
         + fuel + pctCollege + rooms*bedrooms + rooms*bathrooms 
         + rooms*heating + livingArea, data=saratoga_train)

# Add some interactions that definitely determine value like valueSqFt, ageSq, landValue*age
lm3 = lm(price ~ lotSize + landValue + waterfront + lotSize*livingArea #intrinsic land qualities
        + age + ageSq + bedrooms*bathrooms + heating + centralAir + livingArea + newConstruction #house qualities
        + rooms*bedrooms + rooms*bathrooms + rooms*heating + landValue*age #interacting house qualities
        + pctCollege + valueSqFt, data=saratoga_train) #neighborhood qualities

# Predictions out of sample
yhat_test1 = predict(lm1, saratoga_test)
yhat_test2 = predict(lm2, saratoga_test)
yhat_test3 = predict(lm3, saratoga_test)


rmse = function(y, yhat) {
  sqrt( mean( (y - yhat)^2 ) )
}

# Root mean-squared prediction error
rmse(saratoga_test$price, yhat_test1)
  ### RMSE = 66,555
rmse(saratoga_test$price, yhat_test2)
  ### RMSE = 61,401
rmse(saratoga_test$price, yhat_test3)
  ### rmse = 61,092

# easy averaging over train/test splits
library(mosaic)

rmse_vals = do(100)*{
  
  # re-split into train and test cases
  n_train = round(0.8*n)  # round to nearest integer
  n_test = n - n_train
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  saratoga_train = SaratogaHouses[train_cases,]
  saratoga_test = SaratogaHouses[test_cases,]
  
  # fit to this training set
  lm1 = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
                        fireplaces + bathrooms + rooms + heating + fuel + centralAir, data=SaratogaHouses)
  
  lm_boom = lm(price ~ lotSize + age + pctCollege + 
                 fireplaces + rooms + heating + fuel + centralAir +
                 bedrooms*rooms + bathrooms*rooms + 
                 bathrooms*livingArea, data=saratoga_train)
  
  lm_biggerboom = lm(price ~ lotSize + landValue + waterfront + lotSize*livingArea 
                     + age + ageSq + bedrooms*bathrooms + heating + centralAir + livingArea + newConstruction
                     + rooms*bedrooms + rooms*bathrooms + rooms*heating + landValue*age
                     + pctCollege + valueSqFt, data=saratoga_train)
  
  
  # predict on this testing set
  yhat_test1 = predict(lm1, saratoga_test)
  yhat_testboom = predict(lm_boom, saratoga_test)
  yhat_testbiggerboom = predict(lm_biggerboom, saratoga_test)
  c(rmse(saratoga_test$price, yhat_test2),
    rmse(saratoga_test$price, yhat_testboom),
    rmse(saratoga_test$price, yhat_testbiggerboom))
}

rmse_vals
colMeans(rmse_vals)

#applying the biggerboom model to every observation
SaratogaHouses$prediction <- predict(lm_biggerboom)

###### PART 2 ######
###Turn your model into a better performing KNN model 
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
saratoga_train = SaratogaHouses[train_cases,]
saratoga_test = SaratogaHouses[test_cases,]

# Now separate the training and testing sets into features (X) and outcome (y)
X_train = select(saratoga_train, yhat_testbiggerboom)
y_train = select(n_train, price)

X_test = select(saratoga_test, lotSize + landValue + waterfront + lotSize*livingArea 
                + age + ageSq + bedrooms*bathrooms + heating + centralAir + livingArea + newConstruction
                + rooms*bedrooms + rooms*bathrooms + rooms*heating + landValue*age
                + pctCollege + valueSqFt, data=saratoga_train)
y_test = select(n_test, price)
