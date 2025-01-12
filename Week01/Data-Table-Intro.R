## ---- echo=TRUE------------------------------------------------------------------------------------
library(data.table) 
 
## We can directly create a data.table just like a dataframe 
dt1 <-  
  data.table(x1=1:10, 
             x2=10:1) 
dt1 
str(dt1) 
is.data.frame(dt1) 
is.data.table(dt1) 


## ---- echo=TRUE------------------------------------------------------------------------------------
library(data.table) 
library(plyr) # for the baseball data
 
## We can convert existing dataframe to dt 
data(baseball) 
str(baseball) 
baseball_dt <-  
  data.table(baseball) 
 
## Fast File Read 
cohort <- fread("patient_demo.csv") 


## --------------------------------------------------------------------------------------------------
## how much faster?
system.time(cohort <- read.csv("patient_demo.csv"))
library(readr)
system.time(cohort <- read_csv("patient_demo.csv"))
system.time(cohort <- fread("patient_demo.csv"))


## ---- echo=TRUE------------------------------------------------------------------------------------
## list all data.tables and their size 
tables() 
 
## Confirm this is a data.table (and a data frame) 
class(cohort) 
 
## the usual methods for data.frames all work for  
summary(cohort) 
 
## Data.tables print the first and last 5 rows 
cohort 


## ---- echo=TRUE------------------------------------------------------------------------------------
cohort[] # prints all 
## the first row 
cohort[i=1] 
## we usually don't bother naming the argument with i= 
## Rows 10 to 20 
cohort[10:20] 


## ---- echo=TRUE------------------------------------------------------------------------------------
## all patients older than 50 
cohort[age>50] 
 
## all patients older than 50 and male 
cohort[age>50 & gender == "Male"] 


## ---- echo=TRUE------------------------------------------------------------------------------------
baseball_dt[1:10] 
baseball_dt[year > 2000] 
baseball_dt[team %in% c("NYN","CLE")] 


## ---- echo=TRUE------------------------------------------------------------------------------------
## Returns age as a vector 
cohort[,j=age][1:10] 
## we typically omit the j= piece 
cohort[,age][1:10]
## Adding list() returns a data.table 
cohort[,list(age)] 
cohort[,list(age,patient_id)] 
## use . as a shortcut for list here 
cohort[,.(age,patient_id)] 


## ---- echo=TRUE------------------------------------------------------------------------------------
baseball_dt[year > 2000,list(id,year,team)] 
baseball_dt[year > 2000,.(id,year,team)] 
 
## How many rows? 
nrow(baseball_dt[year > 2000,.(id,year,team)]) 


## ---- echo=TRUE------------------------------------------------------------------------------------
# These work as expected 
cohort[,1] 
cohort[,"age"] 


## ---- echo=TRUE, error=TRUE------------------------------------------------------------------------
# These do not!
var_num <- 1
cohort[,var_num] 
cohort[,..var_num] # works
var_name <- "age"
cohort[,var_name] 
cohort[,..var_name] # works


## ---- echo=TRUE------------------------------------------------------------------------------------
## here is the average and SD of age 
cohort[,mean(age)] 
cohort[,sd(age)] 
## Returned as a data.table 
cohort[,list(mean(age), 
             sd(age))] 
## Name each column in the result 
cohort[,list(avg=mean(age), 
             stdev=sd(age))] 


## ---- echo=TRUE------------------------------------------------------------------------------------
baseball_dt[,list(mean(hr))] 
baseball_dt[,list(tot_ab = sum(ab), 
                  tot_rbi = sum(rbi,na.rm=T), 
                  tot_hous = sum(team=="HOU"))] 
 


## ---- echo=TRUE------------------------------------------------------------------------------------
## here is a table of gender by mortality 
cohort[,table(gender,mortality)] 
## With row proportions 
cohort[,prop.table(table(gender,mortality),1)] 
 
## chi-square test on gender and mortality 
cohort[,chisq.test(gender,mortality)] 


## ---- echo=TRUE------------------------------------------------------------------------------------
## logistic regression on mortality 
mod_result_1 <-  
  cohort[,glm(mortality == "Yes" ~ age + gender + SES, 
              family = "binomial")] 
summary(mod_result_1) 

## all in one step 
cohort[,summary(glm(mortality == "Yes" ~ age + gender + SES, 
                    family = "binomial"))] 


## ---- echo=TRUE------------------------------------------------------------------------------------
## Lets select patient_id, age, and add log age 
cohort[,list(patient_id, 
             age, 
             l_age=log(age))] 


## ---- echo=TRUE------------------------------------------------------------------------------------
## Average age by different gender levels 
cohort[,mean(age),by=gender] 
## Use a named list to name the variable 
cohort[,list(avg_age=mean(age)), 
       by=gender] 
## Return multiple columns 
cohort[,list(avg_age=mean(age), 
             sd_age=sd(age)), 
       by=gender] 


## ---- echo=TRUE------------------------------------------------------------------------------------
baseball_dt[year > 2000, 
            list(avg_rbi=mean(rbi,na.rm=T), 
                 tot_rbi=sum(rbi,na.rm=T)), 
            by=team] 
baseball_dt[year > 2000, 
            list(avg_rbi=mean(rbi,na.rm=T), 
                 tot_rbi=sum(rbi,na.rm=T)), 
            by=lg] 


## ---- echo=TRUE------------------------------------------------------------------------------------
## multiple by variables using list 
cohort[,list(age=mean(age)),
       by=list(gender,SES)] 
 
## multiple by variables using character vector 
cohort[,list(age=mean(age)),
       by=c("gender","SES")] 
 
## Use an expression for a by level 
cohort[,list(age=mean(age)), 
       by=list(gender,young=age<50)] 


## ---- echo=TRUE------------------------------------------------------------------------------------
res1 <-  
  baseball_dt[year > 2000, 
            list(avg_rbi=mean(rbi,na.rm=T), 
                 tot_rbi=sum(rbi,na.rm=T)), 
            by=team] 
setorder(res1,avg_rbi) 
res1

## Same thing, but no intermediate object
## Does not order in place
res1 <- 
  baseball_dt[year > 2000, 
            list(avg_rbi=mean(rbi,na.rm=T), 
                 tot_rbi=sum(rbi,na.rm=T)), 
            by=team][order(avg_rbi)] 
 


## ---- echo=TRUE------------------------------------------------------------------------------------
## extract the p-values for age and mortality 
cohort[,summary(lm(age ~ gender + mortality))$coefficients[2,4], 
       by=hosp_id] 

