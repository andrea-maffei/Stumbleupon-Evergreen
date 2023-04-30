
source("~/Desktop/Masters/Classes/Machine Learning/Data for Class/BabsonAnalytics.r")
df<-read.csv("~/Desktop/Masters/Classes/Machine Learning/Projects/Evergreen - stumbleupon/Data/train.csv")

library(ggplot2)
library(caret)

#MANAGE

df$boilerplate<-NULL
df$url<-NULL
df$urlid<-NULL
df$alchemy_category_score<-NULL
#df$framebased<-NULL

df$alchemy_category<-as.factor(df$alchemy_category)
df$is_news<-as.factor(df$is_news)
df$lengthyLinkDomain<-as.factor(df$lengthyLinkDomain)
df$news_front_page<-as.factor(df$news_front_page)
df$hasDomainLink<-as.factor(df$hasDomainLink)
df$label<-as.logical(df$label)
df$framebased<-as.logical(df$framebased)


#PARTITION
N<-nrow(df) 
training_size<-round(N*0.6) 
training_cases<-sample(N, training_size)
training<-df[training_cases, ]
test<-df[-training_cases, ]

#BUILD
model<-glm(label ~., data<-training, family=binomial)
model = step(model)
summary(model)

pred = predict(model, test, type='response')
predTF = (pred > 0.70)

observations<-test$label
table(predTF, observations)

errorRate = sum(predTF != test$label)/nrow(test)
errorBench = benchmarkErrorRate(training$label, test$label)
ROCChart(observations,pred)
liftChart(observations,pred)

