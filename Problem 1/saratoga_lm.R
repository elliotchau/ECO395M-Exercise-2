library(tidyverse)
library(mosaic)
data(SaratogaHouses)
summary(SaratogaHouses)

###### PART 1 ######
  ###Build a better model than "lm_medium" in the starter script
  ###Any particularly strong drivers of house price?

# Compare out-of-sample predictive performance
#### Create some new variables to include in the model
  # intrinsic land value to size of living area ($/sq ft)
SaratogaHouses$valueSqFt <- SaratogaHouses$landValue/SaratogaHouses$livingArea
  # age squared; older houses significantly drop in value
SaratogaHouses$ageSq <- SaratogaHouses$age*SaratogaHouses$age
  # convert categorical variables into dummies
SaratogaHouses$waterfrontDummy <- ifelse(SaratogaHouses$waterfront == 'Yes', 1, 0)
SaratogaHouses$newConstructionDummy <- ifelse(SaratogaHouses$newConstruction == 'Yes', 1, 0)
SaratogaHouses$centralAirDummy <- ifelse(SaratogaHouses$centralAir == 'Yes', 1, 0)


# In sample estimation models
# The baseline "medium" model
lm1 = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
     fireplaces + bathrooms + rooms + heating + fuel + centralAirDummy, data=SaratogaHouses)

# Adding land value and interactions with rooms and bedrooms (from class)
  # The logic is that bathrooms should match bedrooms so you don't have to wait forever
  # Also heated rooms 
lm2 = lm(price ~ lotSize + landValue + waterfrontDummy + newConstructionDummy + bedrooms*bathrooms + heating 
        + centralAirDummy + pctCollege + rooms*bedrooms + rooms*bathrooms 
        + rooms*heating + livingArea + valueSqFt + ageSq, data=SaratogaHouses)

# Add some interactions
lm3 = lm(price ~ lotSize + landValue + waterfrontDummy + lotSize*livingArea
        + age + ageSq + bedrooms*bathrooms + heating + centralAirDummy + livingArea + newConstructionDummy
        + rooms*bedrooms + rooms*bathrooms + rooms*heating + landValue*age
        + pctCollege + valueSqFt, data=SaratogaHouses)
summary(lm3)

# Model predictions
yhat_test1 = predict(lm1, SaratogaHouses)
yhat_test2 = predict(lm2, SaratogaHouses)
yhat_test3 = predict(lm3, SaratogaHouses)

# RMSE function
rmse = function(y, yhat) {
  sqrt( mean( (y - yhat)^2 ) )
}

rmse(SaratogaHouses$price, yhat_test1)
  ### RMSE = 66,015
rmse(SaratogaHouses$price, yhat_test2)
  ### RMSE = 57,154
rmse(SaratogaHouses$price, yhat_test3)
  ### rmse = 56,760

# easy averaging over train/test splits
library(mosaic)
rmse_vals = do(100)*{
  
  # re-split into train and test cases
  n = nrow(SaratogaHouses)
  n_train = round(0.8*n)  # round to nearest integer
  n_test = n - n_train
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  saratoga_train = SaratogaHouses[train_cases,]
  saratoga_test = SaratogaHouses[test_cases,]
  
  # fit to this training set
  lm1 = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
             fireplaces + bathrooms + rooms + heating + fuel + centralAirDummy, data=saratoga_train)
  
  lm2 = lm(price ~ lotSize + landValue + waterfrontDummy + newConstructionDummy + bedrooms*bathrooms + heating 
          + centralAirDummy + pctCollege + rooms*bedrooms + rooms*bathrooms 
          + fuel + rooms*heating + livingArea + valueSqFt + ageSq, data=saratoga_train)
  
  lm3 = lm(price ~ lotSize + landValue + waterfrontDummy + lotSize*livingArea
           + age + ageSq + bedrooms*bathrooms + heating + centralAirDummy + livingArea + newConstructionDummy
           + rooms*bedrooms + rooms*bathrooms + rooms*heating + landValue*age
           + pctCollege + valueSqFt, data=saratoga_train)
  
  # predict on this testing set
  yhat_test1 = predict(lm1, saratoga_test)
  yhat_test2 = predict(lm2, saratoga_test)
  yhat_test3 = predict(lm3, saratoga_test)
  c(rmse(saratoga_test$price, yhat_test1),
    rmse(saratoga_test$price, yhat_test2),
    rmse(saratoga_test$price, yhat_test3))
}

rmse_vals
colMeans(rmse_vals)


##################################### PART 2 ########################################
library(FNN)
library(foreach)

### Turn your model into a better performing KNN model 
# Run it many times to get better results
rmse_vals = do(250)*{
  
  n = nrow(SaratogaHouses)
  n_train = round(0.8*n)  # round to nearest integer
  n_test = n - n_train
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases)
  saratoga_train = SaratogaHouses[train_cases,]
  saratoga_test = SaratogaHouses[test_cases,]

  # Fit to the training data
  lm1 = lm(price ~ lotSize + age + livingArea + pctCollege + bedrooms + 
           fireplaces + bathrooms + rooms + heating + fuel + centralAirDummy, data=saratoga_train)

  lm2 = lm(price ~ lotSize + landValue + waterfrontDummy + newConstructionDummy + bedrooms*bathrooms + heating 
         + centralAirDummy + pctCollege + rooms*bedrooms + rooms*bathrooms 
         + fuel + rooms*heating + livingArea + valueSqFt + ageSq, data=saratoga_train)

  lm3 = lm(price ~ lotSize + landValue + waterfrontDummy + lotSize*livingArea
         + age + ageSq + bedrooms*bathrooms + heating + centralAirDummy + livingArea + newConstructionDummy
         + rooms*bedrooms + rooms*bathrooms + rooms*heating + landValue*age
         + pctCollege + valueSqFt, data=saratoga_train)

  # Predictions out of sample
  yhat_test1 = predict(lm1, saratoga_test)
  yhat_test2 = predict(lm2, saratoga_test)
  yhat_test3 = predict(lm3, saratoga_test)

  # Root mean-squared prediction error
  rmse(saratoga_test$price, yhat_test1)
  rmse(saratoga_test$price, yhat_test2)
  rmse(saratoga_test$price, yhat_test3)

  # construct the training and test-set feature matrices
  # note the "-1": this says "don't add a column of ones for the intercept"
  Xtrain = model.matrix(~ . - (price + sewer + fireplaces + waterfront + centralAir + newConstruction) - 1, data=saratoga_train) 
  Xtest = model.matrix(~ . - (price + sewer + fireplaces + waterfront + centralAir + newConstruction) - 1, data=saratoga_test)

  # training and testing set responses
  ytrain = saratoga_train$price
  ytest = saratoga_test$price

  # now rescale:
  scale_train = apply(Xtrain, 2, sd)  # calculate std dev for each column
  Xtilde_train = scale(Xtrain, scale = scale_train)
  Xtilde_test = scale(Xtest, scale = scale_train)  # use the training set scales!
}

# Run the plot line to find where it bottoms out
#K = 15
# fit the model
knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=6)

k_grid = exp(seq(log(2), log(300), length=100)) %>% round %>% unique
rmse_grid = foreach(K = k_grid, .combine='c') %do% {
    knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=K)
    rmse(ytest, knn_model$pred)
  }
plot(k_grid, rmse_grid, log='x')

# calculate test-set performance
rmse(ytest, knn_model$pred)
