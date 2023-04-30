library(randomForest)
library(rpart)
library(readr)
library(ggplot2)
library(caret)
df=read.csv('/Users/guangyu/Desktop/trainnew.csv')
source('/Users/guangyu/Desktop/ml data/BabsonAnalytics.r')

#########################################Random Forest###########################
df$label= as.logical(df$label)
df$boilerplate=NULL
df$url=NULL
df$urlid=NULL
df$alchemy_category=as.factor(df$alchemy_category)
df$framebased=NULL
df$alchemy_category_score<-NULL
df$hasDomainLink=as.factor(df$hasDomainLink)
df$is_news=as.factor(df$is_news)
df$lengthyLinkDomain=as.factor(df$lengthyLinkDomain)
df$news_front_page=as.factor(df$news_front_page)
df$title=str_length(df$title)
df$body=nchar(df$body)

set.seed(1234)
N = nrow(df)
trainingSize  = round(N*0.6)
trainingCases = sample(N, trainingSize)
training  = df[trainingCases,]
test      = df[-trainingCases,]

rf = randomForest(label ~ ., data= training, ntree=500,type='class')
pred_rf = predict(rf, test)
pred_rf = (pred_rf > 0.5)

error_rf = sum(pred_rf!=test$label)/nrow(test)

####################################Naive Bayes######################3
library(readr)
library(tidytext)
library(tidyverse)

df=read.csv('/Users/guangyu/Desktop/trainnew.csv')
df$boilerplate = as.character(df$boilerplate)
df = df %>% unique()
df = df %>% mutate(ID = c(1:nrow(df)))

df = df[,c("ID","boilerplate","label")]
# df$label = df$label == "1"

outcome = df %>% select(ID, label)

word_list = df %>% unnest_tokens(word, `boilerplate`) %>%
  group_by(ID) %>% 
  distinct() %>%
  ungroup() %>%    
  anti_join(stop_words) %>%
  count(word, sort = TRUE) %>%
  filter(n >= 50) %>%
  pull(word)

bag_of_words = df %>% unnest_tokens(word, `boilerplate`) %>%
  group_by(ID) %>% 
  distinct() %>%
  ungroup() %>%  
  count(ID, word) %>%
  filter(word %in% word_list) %>%
  pivot_wider(id_cols = ID, names_from = word, values_from = n) %>%
  right_join(outcome, by="ID") %>%
  replace(is.na(.), 0)  %>%
  select(-ID)

nbdf=read.csv('/Users/guangyu/Desktop/trainnew.csv')
nbdf = cbind(nbdf$label,bag_of_words)
colnames(nbdf)[1] = "label"

everyColumn = colnames(nbdf)
nbdf[everyColumn] = lapply(nbdf[everyColumn], factor)

idx = sample(nrow(nbdf),0.75*nrow(nbdf))
trn = nbdf[ idx,]
tst = nbdf[-idx,]
library(e1071)
nb = naiveBayes(label ~ ., data = trn)
pred_nb = predict(nb, tst)

error_nb = sum(pred_nb != tst$label)/nrow(tst)

####################################Naive Bayes######################3

pred_nb_full = predict(nb, nbdf)
pred_rf_full = predict(rf, df)

df_stacked = cbind(df,pred_nb_full, pred_rf_full)

df$label=as.logical(df$label)
train_stacked = df_stacked[trainingCases, ]
test_stacked = df_stacked[-trainingCases, ]

stacked = glm(label ~ ., data = train_stacked, family=binomial)

pred_stacked = predict(stacked, test_stacked, type="response")
pred_stacked = (pred_stacked > 0.5)


error_stacked = sum(pred_stacked != test_stacked$label)/nrow(test_stacked)


