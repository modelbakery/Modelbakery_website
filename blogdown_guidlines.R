# R Blog Tutorial Quidlines 


# 1.0 Step up ----
# install.packages('blogdown')
# install_hugo()
# new_site(theme = "wowchemy/starter-academic") # copied the theme from repository 


# start_server()
# serve_site()

# 2.0 .gitignore ----
# go to .gitignore *Add these to ignore*
# .DS_Store
#  Thumbs.db
# 
# commend
# check_gitignore() *Check* whether they have been removed and checked*

# go to .gitignore *Add these to ignore*
# /public
# /resources

# commend 
# check_content()

Having __prior knowledge__ is a key to successful feature engineering. RFM metrics should not be an exception. Especially knowing that RFM is starting journey of understanding customer, not a final deployment. This data unfortunately does not hold background information (supplied by Regi found on Kaggle community). Instead, there are time stamps and sales components (revenue), and additionally campaign customer response flag data. From what is given lets pull some insights and write in it on our perspective note.


Broadly speaking, there are two types of time series data: stationary and non-stationary time series. These are defined as whether their statistical properties, in general, mean and variance is independent (stationary) or dependent (non-stationary) with time. 

Any human interactive data would not be stationary, there will always be some trend or seasonality that enables us to decompose from its series. In other words, understanding these components will aid tracking down their purchasing patterns.

> A distribution is simply a collection of data, or scores, on a variable. Usually, these scores are arranged in order from smallest to largest and then they can be presented graphically. 

--- Page 6, Statistics in Plain English, Third Edition, 2010.

In the context of marketing, this argues that every customers are its unique score itself in a given dimensional space. Depending on how you define an aspect or feature of a situation, problem or thing, these customers can be  quantitatively presented 

Having this is mind we will begin to explore individual RFM components and how to scale and build this matrics from a scratch. 


