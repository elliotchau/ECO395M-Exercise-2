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
  
  lm2 = lm(price ~ lotSize + age + pctCollege + 
                 fireplaces + rooms + heating + fuel + centralAir +
                 bedrooms*rooms + bathrooms*rooms + 
                 bathrooms*livingArea, data=saratoga_train)
  
  lm3 = lm(price ~ lotSize + landValue + waterfront + lotSize*livingArea 
                     + age + ageSq + bedrooms*bathrooms + heating + centralAir + livingArea + newConstruction
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


############################### PART 2 ###########################################################
library(FNN)
library(foreach)

###Turn your model into a better performing KNN model 
 
n = nrow(SaratogaHouses)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
saratoga_train = SaratogaHouses[train_cases,]
saratoga_test = SaratogaHouses[test_cases,]


# Fit to the training data
lm1 = lm(price ~ lotSize + bedrooms + bathrooms, data=saratoga_train)
lm2 = lm(price ~ . - sewer - waterfront - landValue - newConstruction, data=saratoga_train)
lm3 = lm(price ~ lotSize + landValue + waterfront + lotSize*livingArea
         + age + ageSq + bedrooms*bathrooms + heating + centralAir + livingArea + newConstruction
         + rooms*bedrooms + rooms*bathrooms + rooms*heating + landValue*age
         + pctCollege + valueSqFt, data=saratoga_train) 

# Predictions out of sample
yhat_test1 = predict(lm1, saratoga_test)
yhat_test2 = predict(lm2, saratoga_test)
yhat_test3 = predict(lm3, saratoga_test)


rmse = function(y, yhat) {
  sqrt( mean( (y - yhat)^2 ) )
}

# Root mean-squared prediction error
rmse(saratoga_test$price, yhat_test1)
rmse(saratoga_test$price, yhat_test2)
rmse(saratoga_test$price, yhat_test3)

  
# construct the training and test-set feature matrices
# note the "-1": this says "don't add a column of ones for the intercept"
Xtrain = model.matrix(~ . - (price + sewer + fuel + fireplaces) - 1, data=saratoga_test) 
Xtest = model.matrix(~ . - (price + sewer + fuel + fireplaces) - 1, data=saratoga_test)


# training and testing set responses
ytrain = saratoga_train$price
ytest = saratoga_test$price

# now rescale:
scale_train = apply(Xtrain, 2, sd)  # calculate std dev for each column
Xtilde_train = scale(Xtrain, scale = scale_train)
Xtilde_test = scale(Xtest, scale = scale_train)  # use the training set scales!

  K = 10

  # fit the model
  knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=K)

  # calculate test-set performance
  rmse(ytest, knn_model$pred)
  rmse(ytest, yhat_test3)

  k_grid = exp(seq(log(2), log(300), length=100)) %>% round %>% unique
  rmse_grid = foreach(K = k_grid, .combine='c') %do% {
    knn_model = knn.reg(Xtilde_train, Xtilde_test, ytrain, k=K)
    rmse(ytest, knn_model$pred)
  }
  
plot(k_grid, rmse_grid, log='x')
