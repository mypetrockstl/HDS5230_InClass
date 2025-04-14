library(xgboost)
library(mlbench)
library(data.table)
library(caret)
# library(microbenchmark)
library(purrr)

data("PimaIndiansDiabetes2")
dt <- data.table(PimaIndiansDiabetes2)
summary(dt) # note the presence of observations with missing values
dt <- na.omit(dt)
dt[, outcome := ifelse(diabetes == "pos", 1, 0)]

set.seed(2021)
tr.rows <- createDataPartition(y = dt$diabetes,
                               p = 0.8)


## Let's create the "efficient" data structure that is part of the input to
## xgboost()
yvec <- as.integer(dt[tr.rows$Resample1, 10]$outcome)
dim(yvec)
dmatrix <- as.matrix(dt[tr.rows$Resample1, -c(9,10)])
dim(dmatrix)

inputdata <- xgb.DMatrix(data = dmatrix,
                         label = yvec)

## build a "default" version of the xgboost model
bst <- xgboost(inputdata,
               max.depth = 2,
               eta = 1,
               nthread = 2,
               nrounds = 2,
               objective = "binary:logistic")

## What remains now is to determine how many rounds to use on the basis of
## the output of fitting on training data, with a goal of avoiding overfitting
testdata <-as.matrix(dt[-tr.rows$Resample1, -c(9,10)])
pred <- predict(bst, testdata)
pred
err <- mean(as.numeric(pred > 0.5) != (dt[-tr.rows$Resample1, 10]$outcome))
err

## Let us examine how the test-set (i.e. holdout-set) error changes
## as a function of nrounds used in training
maxrounds <- 20
# errvec <- as.numeric(maxrounds)
getResults <- function(nround){
  bst <- xgboost(inputdata,
                 max.depth = 2,
                 eta = 1,
                 nthread = 2,
                 nrounds = nround,
                 verbose = 0,
                 objective = "binary:logistic")

  ## What remains now is to determine how many rounds to use on the basis of
  ## the output of fitting on training data, with a goal of avoiding overfitting
  testdata <-as.matrix(dt[-tr.rows$Resample1, -c(9,10)])
  pred <- predict(bst, testdata)
  pred
  err <- mean(as.numeric(pred > 0.5) != (dt[-tr.rows$Resample1, 10]$outcome))
  err
}
errvals <- map_dbl(1:maxrounds,
                   getResults)
errvals
## a quick plot to visualize the change in holdout-set error
plot(x = 1:maxrounds,
     y = 100 - errvals,
     type = 's',
     xlab = "Number of training rounds",
     ylab = "Prediction error - % wrong guesses",
     main = "Prediction error across no. of training rounds")

##-------------------------------------------##
## let's try the caret interface to xgboost  ##
##-------------------------------------------##
set.seed(2021)
trainIndices <- createDataPartition(dt$diabetes,
                                    p = 0.8)
training <- dt[trainIndices$Resample1, ]
holdout <- dt[-trainIndices$Resample1, ]

## create settings for cross-validation to be used
## we will use repeated k-fold CV. For the sake of time
## we will use 5-fold CV with 1 repetitions
fitControl <- trainControl(
  method = "repeatedcv", ## perform repeated k-fold CV
  number = 5,
  repeats = 1,
  classProbs = TRUE)

#grid <- expand.grid(mtry = 1:(ncol(trainTransformed)-1))

xgbfit <- train(diabetes ~ . - outcome,
                   data = training,
                   method = "xgbTree",
                   trControl = fitControl,
                   verbose = FALSE
                   )

## check what information is available for the model fit
names(xgbfit)

## some plots
trellis.par.set(caretTheme())
plot(xgbfit)

## make predictions on the hold-out set
predvals <- predict(xgbfit, holdout)

## create the confusion matrix and view the results
confusionMatrix(predvals, holdout$diabetes)
## Rank the variables in terms of their importance
varImp(xgbfit)

