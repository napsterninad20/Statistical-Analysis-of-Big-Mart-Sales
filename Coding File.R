rm(list=ls())
library(rio)

#Reading the Excel file
BMS=import("BigMartSales.xlsx", sheet="Data")
colnames(BMS)=tolower(make.names(colnames(BMS)))
attach(BMS)
str(BMS)
summary(BMS)  #Checking the summary                         

#Checking for null values
colSums(is.na(BMS)) #Checking for null values by each columns
sum(is.na(BMS))     #Checking for null values in whole data frame

#Data Pre-processing
#I am replacing item_weight's missing values with mean of the column because
#if I remove all the missing values, there will not be much of the data to predict
#the dependent variable. 
BMS$item_weight[is.na(BMS$item_weight)] = mean(BMS$item_weight, na.rm = T)
sum(is.na(BMS$item_weight))

#I am replacing outlet_type a categorical variable with a new category called
#"unavailable". So that I do not reduce my data. 
library(dplyr)
BMS <- BMS %>%
       mutate(outlet_size = replace(outlet_size, is.na(outlet_size),
                                    "unavailable"))
sum(is.na(BMS$outlet_size))

#Null value final check
sum(is.na(BMS))

#Data Visualizations
library(lattice)
densityplot(~item_sales, data=BMS, main = "Density plot of item_sales")
densityplot(~item_sales | outlet_type, data=BMS,
            main = "Density plot of item_sales by outlet_type")
densityplot(~item_sales | city_type, data=BMS, 
            main = "Density plot of item_sales by city_type")

bwplot(item_sales~outlet_type, data = BMS)
bwplot(item_sales~city_type | outlet_type , data = BMS, 
       main = "Box plot of item_sales by city_type/outlet_type")

xyplot(item_sales ~ outlet_year | outlet_type, data = BMS, 
       main="item_sales v outlet_year by outlet_type") 
hist(item_sales)
hist(item_weight)
hist(item_mrp)
hist(item_visibility)

#Data Scaling because we exactly don't know the units in some variables
BMS$item_weight=scale(BMS$item_weight)
BMS$item_visibility=scale(BMS$item_visibility)
BMS$item_mrp=scale(BMS$item_mrp)

#Converting variables in factor
BMS$item_fat_content=as.factor(BMS$item_fat_content)
BMS$outlet_id=as.factor(BMS$outlet_id)
BMS$outlet_size=as.factor(BMS$outlet_size)
BMS$city_type=as.factor(BMS$city_type)
BMS$outlet_type=as.factor(BMS$outlet_type)

#Q1: What type of outlet will give him best return?===========================================
unique(BMS$outlet_type)
#Models
#Fixed Effect
Fixedoutlet_type = lm (item_sales ~ item_weight + item_fat_content + item_visibility 
                                    + item_mrp + outlet_size + city_type + 
                                    outlet_type, data = BMS)
summary(Fixedoutlet_type)

#Random Effect model
library(lme4)
Randomoutlet_type = lmer (item_sales ~ item_weight + item_fat_content + item_visibility 
                                       + item_mrp + outlet_size + city_type + 
                                       (1 | outlet_type), data = BMS, REML = FALSE)
summary(Randomoutlet_type)
confint(Randomoutlet_type)
AIC(Randomoutlet_type)
fixef(Randomoutlet_type)
ranef(Randomoutlet_type)

#Q2:What type of city will return him the best sales: Tier 1, 2 or 3================================
#Fixed Effect Model
Fixedcity_type = lm (item_sales ~ item_weight + item_fat_content + item_visibility 
                                  + item_mrp + outlet_size + outlet_type +
                                  city_type, data = BMS)

summary(Fixedcity_type)

#Random Effect model
library(lme4)
Randomcity_type = lmer (item_sales ~ item_weight + item_fat_content + item_visibility 
                                     + item_mrp + outlet_size +
                                     (1 | city_type), data = BMS, REML = FALSE)

summary(Randomcity_type)
confint(Randomcity_type)
AIC(Randomcity_type)
fixef(Randomcity_type)
ranef(Randomcity_type)

#Q3: What are the top 3 highest performing and lowest performing stores in the sample.===============
unique(outlet_id) #To check how many unique values
#I would like to apply random effect model here
unique(BMS$outlet_id)
str(BMS$outlet_id)
Randomoutlet_id = lmer (item_sales ~ item_weight + item_fat_content + item_visibility 
                                     + item_mrp + outlet_size +
                                     (1 | outlet_id), data = BMS, REML = FALSE)
summary(Randomoutlet_id)
confint(Randomoutlet_id)
AIC(Randomoutlet_id)
fixef(Randomoutlet_id)
ranef(Randomoutlet_id)
  
