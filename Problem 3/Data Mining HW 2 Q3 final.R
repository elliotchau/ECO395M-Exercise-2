library(stargazer)
library(FNN)
library(tidyverse)

online_news <- read.csv("https://raw.githubusercontent.com/jgscott/ECO395M/master/data/online_news.csv")

viral = online_news$shares
for (i in 1:dim(online_news)[1])
{
  if (online_news$shares[i] > 1400)
  {
    viral[i] = 1
  }
  if (online_news$shares[i] <= 1400)
  {
    viral[i] = 0
  }
}
#View(viral)

ON = online_news

#predict shares, then classify as viral or not
XX = as.matrix(ON[,2:37])
shares = online_news$shares

model <- lm(shares ~ ., data = data.frame(XX))
summary(model)

#which X's are significant
XXX = cbind(ON$n_tokens_title, ON$num_hrefs, ON$num_self_hrefs, ON$num_imgs, ON$average_token_length, ON$num_keywords, 
            ON$data_channel_is_lifestyle, ON$data_channel_is_entertainment, ON$data_channel_is_bus, ON$data_channel_is_socmed,
            ON$data_channel_is_tech, ON$data_channel_is_world, ON$self_reference_min_shares, ON$avg_negative_polarity
)

model2 = lm(shares ~ XXX)
summary(model2)

#list of coefficients of parsimonious model
CC = as.numeric(model2$coefficients)

predictedshared=do(100)*{
#predict actual number of shares in parsimonious model
pred = function(r = double()) #r is row of XXX
{
  prediction = CC[1]
  for (i in 2:length(CC))
  {
    add = CC[i]*as.numeric(XX[r,i])
    if (!is.na(add))
    {
      prediction = prediction + CC[i]*as.numeric(XX[r,i])
    }
  }
  
  return(prediction)
}

#use prior predictions (pred) to see if number of shares is above of below threshold
predViral = function(r = double)
{
  pp = pred(r)
  tryCatch({
    if (pp > 1400)
    {
      return(1)
    }
    if (pp <= 1400)
    {
      return(0)
    }
  })
}

}
#get prediction accuracy
predAcc = array(dim=c(length(viral))) #did we predict accurately (1) or not (0) for each observation
for (i in 1:length(viral))
{
  print(i)
  tryCatch({
    PV = predViral(i)
    if (viral[i] == PV && !is.na(viral[i]) && !is.na(PV))
    {
      predAcc[i] = 1
    }
    if (viral[i] != PV && !is.na(viral[i]) && !is.na(PV))
    {
      predAcc[i] = 0
    }
  })
}

mean(predAcc, na.rm=TRUE) #49.54% accuracy

#classification part 
online_news$viral <- as.numeric(online_news$shares > 1400)

ON <- na.omit(online_news)

ON$viral <- as.numeric(ON$shares > 1400)

# re-split into train and test cases
n=nrow(online_news)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
online_news_train = online_news[train_cases,]
online_news_test = online_news[test_cases,]

glm1 = glm(viral ~ average_token_length + num_imgs + num_videos + num_hrefs + weekday_is_saturday , data=online_news, family='binomial')
glm2 = glm(viral ~ num_hrefs +is_weekend + global_rate_negative_words + data_channel_is_bus + self_reference_avg_sharess + data_channel_is_world + data_channel_is_entertainment + num_keywords + avg_negative_polarity, data=online_news, family='binomial')
glm3 = glm(viral ~ (n_tokens_title + num_hrefs + weekday_is_monday + global_rate_positive_words + avg_negative_polarity + max_negative_polarity + is_weekend), data=online_news, family='binomial')

stargazer::stargazer(glm1, glm2, glm3, type= "text")


#in-Sample 

insampledo=do(100)*{

phat_train1 = predict(glm1, online_news_train) 
phat_train2 = predict(glm2, online_news_train) 
phat_train3 = predict(glm3, online_news_train) 

yhat_train1 = ifelse(phat_train1>0.5, 1,0)
yhat_train2 = ifelse(phat_train2>0.5, 1,0)
yhat_train3 = ifelse(phat_train3>0.5, 1,0)

confusion_in1 = table(y = online_news_train$viral, yhat = yhat_train1)

confusion_in2 = table(y = online_news_train$viral, yhat = yhat_train2)

confusion_in3 = table(y = online_news_train$viral, yhat = yhat_train3)

confusion_in1
confusion_in2
confusion_in3

}

sum(diag(confusion_in1))/sum(confusion_in1)
sum(diag(confusion_in2))/sum(confusion_in2) # <------most accurate @ 56.9%
sum(diag(confusion_in3))/sum(confusion_in3)

#Out of sample confusion matrix

outofsample=do(100)*{
phat_test1 = predict(glm1, online_news_test)
phat_test2 = predict(glm2, online_news_test)
phat_test3 = predict(glm3, online_news_test)

yhat_test1 = ifelse(phat_test1 > 0.5,1,0)
yhat_test2 = ifelse(phat_test2 > 0.5,1,0)
yhat_test3 = ifelse(phat_test3 > 0.5,1,0)

confusion_out1 = table(y = online_news_test$viral, yhat = yhat_test1)
confusion_out2 = table(y = online_news_test$viral, yhat = yhat_test2)
confusion_out3 = table(y = online_news_test$viral, yhat = yhat_test3)

confusion_out1
confusion_out2
confusion_out3
}
#overall accuracy of out of sample prediction
sum(diag(confusion_out1))/sum(confusion_out1)
sum(diag(confusion_out2))/sum(confusion_out2) # <-----most accurate @ 57%
1-sum(diag(confusion_out2))/sum(confusion_out2) # opposite of accuracy rate is error rate (lowest)
sum(diag(confusion_out3))/sum(confusion_out3)

#comparison to baseline model 

length(which(online_news$viral == 0))/length(online_news$viral) #50.6%

#################### PART 2##################### #classification model part b using his variable name

viral= ifelse(online_news$shares > 1400, 1, 0)
# re-split into train and test cases
n=nrow(online_news)
n_train = round(0.8*n)  # round to nearest integer
n_test = n - n_train
train_cases = sample.int(n, n_train, replace=FALSE)
test_cases = setdiff(1:n, train_cases)
online_news_train = online_news[train_cases,]
online_news_test = online_news[test_cases,]

glm1 = glm(viral ~ average_token_length + num_imgs + num_videos + num_hrefs + weekday_is_saturday , data=online_news, family='binomial')
glm2 = glm(viral ~ num_hrefs +is_weekend + global_rate_negative_words + data_channel_is_bus + self_reference_avg_sharess + data_channel_is_world + data_channel_is_entertainment + num_keywords + avg_negative_polarity, data=online_news, family='binomial')
glm3 = glm(viral ~ (n_tokens_title + num_hrefs + weekday_is_monday + global_rate_positive_words + avg_negative_polarity + max_negative_polarity + is_weekend), data=online_news, family='binomial')


#In sample
insampleclass=do(100)*{
phat_train1 = predict(glm1, online_news_train) 
phat_train2 = predict(glm2, online_news_train) 
phat_train3 = predict(glm3, online_news_train) 

yhat_train1 = ifelse(phat_train1>0.5, 1,0)
yhat_train2 = ifelse(phat_train2>0.5, 1,0)
yhat_train3 = ifelse(phat_train3>0.5, 1,0)

confusion_in1 = table(y = online_news_train$viral, yhat = yhat_train1)

confusion_in2 = table(y = online_news_train$viral, yhat = yhat_train2)

confusion_in3 = table(y = online_news_train$viral, yhat = yhat_train3)

confusion_in1
confusion_in2
confusion_in3
}

sum(diag(confusion_in1))/sum(confusion_in1)
sum(diag(confusion_in2))/sum(confusion_in2)
sum(diag(confusion_in3))/sum(confusion_in3)

#Out of sample confusion matrix

outofsampleclass=do(100)*{
phat_test1 = predict(glm1, online_news_test)
phat_test2 = predict(glm2, online_news_test)
phat_test3 = predict(glm3, online_news_test)

yhat_test1 = ifelse(phat_test1 > 0.5,1,0)
yhat_test2 = ifelse(phat_test2 > 0.5,1,0)
yhat_test3 = ifelse(phat_test3 > 0.5,1,0)

confusion_out1 = table(y = online_news_test$viral, yhat = yhat_test1)
confusion_out2 = table(y = online_news_test$viral, yhat = yhat_test2)
confusion_out3 = table(y = online_news_test$viral, yhat = yhat_test3)

confusion_out1
confusion_out2
confusion_out3
}
#overall accuracy of out of sample prediction

sum(diag(confusion_out1))/sum(confusion_out1)
sum(diag(confusion_out2))/sum(confusion_out2) # <---- best @ 57.4% accuracy
sum(diag(confusion_out3))/sum(confusion_out3)

#comparison to baseline model 

length(which(online_news$viral == 0))/length(online_news$viral) #<---50.6%

