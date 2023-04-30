library(rpart)
library(rpart.plot)
source("~/Desktop/Masters/Classes/Machine Learning/Data for Class/BabsonAnalytics.r")

#LOAD
df<-read.csv("~/Desktop/Masters/Classes/Machine Learning/Projects/Evergreen - stumbleupon/Data/train.csv")
str(df)

#MANAGE
#df<-subset(df, alchemy_category_score !="?") I don't think to use this

df$alchemy_category<-as.factor(df$alchemy_category)
df$is_news<-as.factor(df$is_news)
df$lengthyLinkDomain<-as.factor(df$lengthyLinkDomain)
df$news_front_page<-as.factor(df$news_front_page)
df$hasDomainLink<-as.factor(df$hasDomainLink)
df$label<-as.factor(df$label)
df$framebased<-as.factor(df$framebased)
df$url<-NULL
df$urlid<-NULL
df$boilerplate<-NULL
df$alchemy_category_score<-NULL


#PARTITION
N<-nrow(df) 
training_size<-round(N*0.6) 
training_cases<-sample(N, training_size)
training<-df[training_cases, ]
test<-df[-training_cases, ]

#BUILD
stopping_rules=rpart.control(minsplit = 50, minbucket = 10, cp=0.01) 
model<-rpart(label ~., data<-training,)#control = stopping_rules)

model<-easyPrune(model)
rpart.plot(model)

#PREDICT
predictions<-predict(model, test, type = "class")

#EVALUATE
observations<-test$label
table(predictions, observations)
error_bench<-benchmarkErrorRate(training$label, test$label)
errorRate = sum(predictions!=test$label)/nrow(test)
