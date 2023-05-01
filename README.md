# Stumbleupon-Evergreen
A repository that contains all of the iterative work for the kaggle competition stumbleupon used for a machine learning course

This repository shows the three phases of creating three different models in order to solve the stumbleupon kaggle comptition.

To outline: 
This competition looked at a trainign dataset with a variety of variables describing thoudands of individual websites. Given these thousands of websites
we were tasked with creating a model that would effectivley take each variable and predict whether the individual website would be evergreen or not
(Evergreen is a term used to describe a website that will have consistant traffic in 6 months time). The variables in the dataset included:
- Boiler plates (string descriptions of websites containing key words)
- urls
- category-scores (these scores derived from the alchemy API, that, given a score would describe the cateogry of a given website)
etc.

With the definition of data variables out of the way, we continue with the construction, testing, and feature testing our models.
In the end we created three different models with which to predict evergreen websites. These models are:
- Logistic Regression
- Classification Tree
- Naïve Bayes

With this final model, we were able to arrive to an accuracy rate of close to 24%. 

When it came to improving the model we used a stacking method to bring together the best parts of each model and brought into a single model.
With this came a further 3% improvement to an error rate of 21%.
