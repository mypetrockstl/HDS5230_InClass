library(xgboost)
data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')

View(agaricus.train)

train <- agaricus.train
test <- agaricus.test

dim(train$data)
dim(test$data)
    
bst <- xgboost(data = train$data,
               label = train$label,
               max.depth=2, 
               eta = 1,
               nthread = 2,
               nrounds=5,
               verbose =2,
               objective = "binary:logistic")

pred <- predict(bst, test$data)
pred

err<- mean(as.numeric(pred > 0.5) != test$label)
print(paste("test-error=", err))
