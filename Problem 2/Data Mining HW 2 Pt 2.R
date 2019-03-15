library(caret)
library(ggplot2)

# Duplicate origial dataset to create train/test data
brcaRe = brca

# Removing Radiologist from the data frame
drop <- c("radiologist")
brcaRe2 = brcaRe[,!(names(brcaRe) %in% drop)]

brcaRe2

# Converting all categorical variables to Dummy variables
dmybrca <- dummyVars("~.", data = brcaRe2, fullRank = T)

brcaRe2 <- data.frame(predict(dmybrca, newdata = brcaRe))

# Converting Recall to a categorical variable
brcaRe2$recall <- as.factor(brcaRe2$recall)

brcaRe2

# Creating train/test split
set.seed(200)
index <- createDataPartition(brcaRe2$recall, p=0.8, list = FALSE)
trainSet <- brcaRe2[index,]
testSet <- brcaRe2[-index,]

str(trainSet)

# Creating a control function to find the best predictors of recall
control <- rfeControl(functions = rfFuncs,
                      method = "repeatedcv",
                      repeats = 4,
                      verbose = FALSE)
outcomeName <- 'recall'
predictors<- names(trainSet)[!names(trainSet) %in% outcomeName]
Recall_Pred_Profile <- rfe(trainSet[,predictors], trainSet[,outcomeName],
                           rfeControl = control)

Recall_Pred_Profile

plot(Recall_Pred_Profile)

# Set top 5 most accurate predictors of recall for use in prediction models
predictors <- c("cancer", "menopause.premeno", "age.age5059", "menopause.postmenoNoHT", "age.age70plus")

# Create multiple training models to find the most accurate prediction model

model_rf <- train(trainSet[,predictors],trainSet[,outcomeName],method='rf') 

model_nnet <- train(trainSet[,predictors],trainSet[,outcomeName],method = 'nnet')

model_glm <- train(trainSet[,predictors],trainSet[,outcomeName],method = 'glm')

# Training models for more accurate results
modelLookup(model = 'glm')
modelLookup(model = 'rf')

# RF model
print(model_rf)

plot(model_rf)

#Train/Tune RF model for better results:
# Control Parameters
RfControl <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 3)

# Training the RF model
model_rfTune <- train(trainSet[,predictors],trainSet[,outcomeName],
                      method='rf', 
                      tuneLength = 4,
                      trControl=RfControl)

model_rfTune$results

plot(model_rfTune)

varImp(model_rfTune)

plot(varImp(object=model_rfTune), main = "RF - Recall Variable Importance")

# Performance Analysis for RF
predictions_rf<-predict.train(object=model_rf, brcaRe2[,predictors],type="raw")
table(predictions_rf)

confusionMatrix(predictions_rf,brcaRe2[,outcomeName])


#RF model shows that, on average, if a patient exhibits the predictor characteristcs, a doctor will recall them for screening with 86% accuracy

# GLM model
model_glm

varImp(model_glm)

plot(varImp(object=model_glm), main = "GLM - Recall Variable Importance")

# Performance Analysis for GLM
predictions_glm<-predict.train(object=model_glm,brcaRe2[,predictors],type="raw")
table(predictions_glm)

confusionMatrix(predictions_glm,brcaRe2[,outcomeName])


# nnet model
model_nnet

plot(model_nnet)

varImp(object=model_nnet)

plot(varImp(object=model_nnet), main = "NNET - Recall Variable Importance")

# Performance Analysis for NNET model
predictions_nnet<-predict.train(object=model_nnet,brcaRe2[,predictors],type="raw")
table(predictions_nnet)

confusionMatrix(predictions_nnet, brcaRe2[,outcomeName])

# Both the GLM and nnet models gives similar results of roughly 85~86% accuracy


# Create new model with cancer as outcome variable and recall as a binary variable
brcaRe3 = brcaRe2

dmybrca2 <- dummyVars("~.", data = brcaRe3, fullRank = T)

brcaRe3 <- data.frame(predict(dmybrca, newdata = brcaRe))

str(brcaRe3)

brcaRe3$cancer <- as.factor(brcaRe3$cancer)

str(brcaRe3)

# Using same train/test split from previous model with cancer as the dependent variable
set.seed(02)
index2 <- createDataPartition(brcaRe3$cancer, p=0.6, list = FALSE)
trainSet2 <- brcaRe3[index2,]
testSet2 <- brcaRe3[-index2,]

str(trainSet2)
str(testSet2)

# Creating a new rf model to try and find the best predictors of cancer
control2 <- rfeControl(functions = rfFuncs,
                      repeats = 3,
                      method = "repeatedcv",
                      verbose = FALSE)
outcomeName2 <- 'cancer'
predictors2<- names(trainSet2)[!names(trainSet2) %in% outcomeName2]
set.seed(808)
Recall_Pred_Profile2 <- rfe(trainSet2[,predictors2], trainSet2[,outcomeName2],
                           rfeControl = control2)

Recall_Pred_Profile2

plot(Recall_Pred_Profile2)

# Use most accurate predictor variables for new model
predictors2 <- c("recall", "density.density4", "age.age6069", "menopause.premeno", "density.density3")

# Use the predictors in regression to test in glm model
model_nnet2 <- train(trainSet2[,predictors2],trainSet2[,outcomeName2],method = 'nnet')

model_glm2 <- train(trainSet2[,predictors2],trainSet2[,outcomeName2],method = 'glm')

# NNET2 model
model_nnet2

varImp(object = model_nnet2)

plot(varImp(object = model_nnet2), main = "NNET - Importance of Variables on Cancer")

# In-Sample Confusion Matrix for NNET 2 model
confusionMatrix(trainSet2$cancer,
                predict(model_nnet2,trainSet2)) 

# Performance Analysis for NNET2
predictions_nnet2<-predict.train(object=model_nnet2, brcaRe3[,predictors2],type="raw")
table(predictions_nnet2)

confusionMatrix(predictions_nnet2,brcaRe3[,outcomeName2])

# NNET2 is an obvious case of over classification for this data set

# GLM2 model
model_glm2

varImp(object=model_glm2)

plot(varImp(object=model_glm2), main = "GLM - Importance of Variables on Cancer")

# In-Sample Confusion Matrix for GLM2 model
confusionMatrix(trainSet2$cancer,
                predict(model_glm2,trainSet2)) 

# Performance Analysis for GLM2
predictions_glm2<-predict.train(object=model_glm2, brcaRe3[,predictors2],type="raw")
table(predictions_glm2)

confusionMatrix(predictions_glm2,brcaRe3[,outcomeName2])

# Final GLM model using recall predictors with cancer as the outcome
set.seed(2222)
index3 <- createDataPartition(brcaRe3$cancer, p=0.6, list = FALSE)
trainSet3 <- brcaRe3[index3,]
testSet3 <- brcaRe3[-index3,]

predictors3 <- c("menopause.premeno", "age.age5059", "menopause.postmenoNoHT", "age.age70plus")

model_glm3 <- train(trainSet3[,predictors3],trainSet3[,outcomeName2],method = 'glm')

model_glm3

varImp(object = model_glm3)

plot(varImp(object = model_glm3), main = "Cancer original variable importance")

# In-Sample Confusion Matrix for GLM3 model
confusionMatrix(trainSet2$cancer,
                predict(model_glm3,trainSet2)) 

# Performance Analysis for GLM3
predictions_glm3<-predict.train(object=model_glm3, brcaRe3[,predictors3],type="raw")
table(predictions_glm3)

confusionMatrix(predictions_glm3,brcaRe3[,outcomeName2])

# Due to rare occurance of cancer, although the model can give accurate predictors for in-sample data and the predictors that it output are still relevent, due to cancer being such a rare outcome, there are not enough samples to give highly accurate out of sample predictions consistently





