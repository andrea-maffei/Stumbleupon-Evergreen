library(readr)
library(tidytext)
library(tidyverse)

df_txt = read.csv('~/Desktop/Masters/Classes/Machine Learning/Projects/Evergreen - stumbleupon/Data/train.csv')
df_txt$boilerplate = as.character(df_txt$boilerplate)
df_txt = df_txt %>% unique()
df_txt = df_txt %>% mutate(ID = c(1:nrow(df_txt)))

df_txt = df_txt[,c("ID","boilerplate","label")]
# df_txt$label = df_txt$label == "1"

outcome = df_txt %>% select(ID, label)

word_list = df_txt %>% unnest_tokens(word, `boilerplate`) %>%
  group_by(ID) %>% 
  distinct() %>%
  ungroup() %>%    
  anti_join(stop_words) %>%
  count(word, sort = TRUE) %>%
  filter(n >= 50) %>%
  pull(word)

# ratio = df_txt %>% 
#   unnest_tokens(word, `boilerplate`) %>%
#   group_by(ID) %>% 
#   distinct() %>%
#   ungroup() %>%
#   filter(word %in% word_list) %>%
#   count(label, word) %>%
#   filter(n >= 100) %>%
#   pivot_wider(names_from = label, values_from = n) %>%
#   replace(is.na(.), 1) %>%
#   mutate(ratio = `1`/`0`) %>%
#   arrange(desc(ratio)) %>%
#   select(word,ratio)
# 
# most_informative_words = combine(tail(ratio$word,100),head(ratio$word,100))

bag_of_words = df_txt %>% unnest_tokens(word, `boilerplate`) %>%
  group_by(ID) %>% 
  distinct() %>%
  ungroup() %>%  
  count(ID, word) %>%
  filter(word %in% word_list) %>%
  pivot_wider(id_cols = ID, names_from = word, values_from = n) %>%
  right_join(outcome, by="ID") %>%
  replace(is.na(.), 0)  %>%
  select(-ID) 

df_nb = read.csv('~/Desktop/Masters/Classes/Machine Learning/Projects/Evergreen - stumbleupon/Data/train.csv')
df_nb = cbind(df_nb$label,bag_of_words)
colnames(df_nb)[1] = "label"

everyColumn = colnames(df_nb)
df_nb[everyColumn] = lapply(df_nb[everyColumn], factor)

idx = sample(nrow(df_nb),0.75*nrow(df_nb))
trn = df_nb[ idx,]
tst = df_nb[-idx,]
library(e1071)
model = naiveBayes(label ~ ., data = trn)
pred = predict(model, tst)

error = sum(pred != tst$label)/nrow(tst)

