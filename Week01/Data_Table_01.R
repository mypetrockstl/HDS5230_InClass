## -------------------------
library(data.table) 
 
## We can directly create a data.table just like a dataframe 
dt1 <-  
  data.table(x1=1:10, 
             x2=10:1) 
dt1 
str(dt1) 
is.data.frame(dt1) 
is.data.table(dt1) 


## -------------------------
library(data.table) 
library(plyr) # for the baseball data
 
## We can convert existing dataframe to dt 
data(baseball) 
str(baseball) 
baseball_dt <-  
  data.table(baseball) 
 
## Fast File Read 
cohort <- fread("patient_demo.csv") 


## ---------------------------------
## how much faster?
system.time(cohort <- read.csv("patient_demo.csv"))
library(readr)
system.time(cohort <- read_csv("patient_demo.csv"))
system.time(cohort <- fread("patient_demo.csv"))


## -------------------------
## list all data.tables and their size 
tables() 
 
## Confirm this is a data.table (and a data frame) 
class(cohort) 
 
## the usual methods for data.frames all work for  
summary(cohort) 
 
## Data.tables print the first and last 5 rows 
cohort 


## -------------------------
cohort[] # prints all 
## the first row 
cohort[i=1] 
## we usually don't bother naming the argument with i= 
## Rows 10 to 20 
cohort[10:20] 


## -------------------------
## all patients older than 50 
cohort[age>50] 
 
## all patients older than 50 and male 
cohort[age>50 & gender == "Male"] 


## -------------------------
baseball_dt[1:10] 
baseball_dt[year > 2000] 
baseball_dt[team %in% c("NYN","CLE")] 


## -------------------------
## Returns age as a vector 
cohort[,j=age][1:10] 
## we typically omit the j= piece 
cohort[,age][1:10]
## Adding list() returns a data.table 
cohort[,list(age)] 
cohort[,list(age,patient_id)] 
## use . as a shortcut for list here 
cohort[,.(age,patient_id)] 


## -------------------------
baseball_dt[year > 2000,list(id,year,team)] 
baseball_dt[year > 2000,.(id,year,team)] 
 
## How many rows? 
nrow(baseball_dt[year > 2000,.(id,year,team)]) 


## -------------------------
# These work as expected 
cohort[,1] 
cohort[,"age"] 


## -------------
# These do not!
var_num <- 1
cohort[,var_num] 
cohort[,..var_num] # works
var_name <- "age"
cohort[,var_name] 
cohort[,..var_name] # works


## -------------------------
## here is the average and SD of age 
cohort[,mean(age)] 
cohort[,sd(age)] 
## Returned as a data.table 
cohort[,list(mean(age), 
             sd(age))] 
## Name each column in the result 
cohort[,list(avg=mean(age), 
             stdev=sd(age))] 


## -------------------------
baseball_dt[,list(mean(hr))] 
baseball_dt[,list(tot_ab = sum(ab), 
                  tot_rbi = sum(rbi,na.rm=T), 
                  tot_hous = sum(team=="HOU"))] 
 


## -------------------------
## here is a table of gender by mortality 
cohort[,table(gender,mortality)] 
## With row proportions 
cohort[,prop.table(table(gender,mortality),1)] 
 
## chi-square test on gender and mortality 
cohort[,chisq.test(gender,mortality)] 


## -------------------------
## logistic regression on mortality 
mod_result_1 <-  
  cohort[,glm(mortality == "Yes" ~ age + gender + SES, 
              family = "binomial")] 
summary(mod_result_1) 

## all in one step 
cohort[,summary(glm(mortality == "Yes" ~ age + gender + SES, 
                    family = "binomial"))] 


## -------------------------
## Lets select patient_id, age, and add log age 
cohort[,list(patient_id, 
             age, 
             l_age=log(age))] 


## -------------------------
## Average age by different gender levels 
cohort[,mean(age),by=gender] 
## Use a named list to name the variable 
cohort[,list(avg_age=mean(age)), 
       by=gender] 
## Return multiple columns 
cohort[,list(avg_age=mean(age), 
             sd_age=sd(age)), 
       by=gender] 


## -------------------------
baseball_dt[year > 2000, 
            list(avg_rbi=mean(rbi,na.rm=T), 
                 tot_rbi=sum(rbi,na.rm=T)), 
            by=team] 
baseball_dt[year > 2000, 
            list(avg_rbi=mean(rbi,na.rm=T), 
                 tot_rbi=sum(rbi,na.rm=T)), 
            by=lg] 


## -------------------------
## multiple by variables using list 
cohort[,list(age=mean(age)),
       by=list(gender,SES)] 
 
## multiple by variables using character vector 
cohort[,list(age=mean(age)),
       by=c("gender","SES")] 
 
## Use an expression for a by level 
cohort[,list(age=mean(age)), 
       by=list(gender,young=age<50)] 


## -------------------------
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
 


## -------------------------
## extract the p-values for age and mortality 
cohort[,summary(lm(age ~ gender + mortality))$coefficients[2,4], 
       by=hosp_id] 


## -------------------------
## Create a new variable and save it to the DT 
cohort[,l_age:=log(age)] 
cohort 
## to erase the variable we assign it a NULL value 
cohort[,l_age:=NULL] 
cohort 
names(cohort) 


## -------------------------
## I use an if-else statement here to create the variable 
cohort[,':='(l_age=log(age), 
             age_cat=ifelse(age<55, "Young", "Less Young"))] 
cohort 
## alternatively, we could have just written two separate lines 
cohort[,l_age:=log(age)] 
cohort[,age_cat:=ifelse(age<55, "Young", "Less Young")] 


## -------------------------
## I can conditionally update values  
## by combining the first two arguments 


## -------------------------
cohort[,avg_age_hosp:=mean(age,na.rm=T), 
       by=hosp_id] 


## -------------------------
## how many players had average rbi above 40 
baseball_dt[year>2000, 
            list(avg_rbi=mean(rbi,na.rm=T)), 
            by=id][avg_rbi > 40] 
## calculate the average rbi by team and year and save it 
baseball_dt[,avg_rbi_team_yr:=mean(rbi,na.rm=T), 
            by=list(team,year)] 


## -------------------------
## Make a copy of a data.table 
cohort2 <- copy(cohort) 

## Use .N 
cohort[,list(avg=mean(age,na.rm=T),.N), 
       by=gender] 

## -------------------------
## Set the key to be hosp_id 
setkey(cohort,hosp_id) 
## notice it is sorted now 
cohort 
## Set the key to be hosp_id, then gender 
setkey(cohort,hosp_id,gender) 
## Set the order to be gender, then descending age 
setorder(cohort,gender,-age)[] 


## -------------------------
setkey(cohort,gender) 
## subset down to hosp_id == 11 
## fast way leveraging the keys, all equivalent 
cohort[list("Male")] 
cohort[.("Male")] 
cohort[J("Male")] 
## slow way (vector scan) 
cohort[gender == "Male"] 


## -------------------------
## subset down to the males with mortality == Yes 
setkey(cohort,gender,mortality) 
cohort[J("Male","Yes")] 


## -------------------------
setkey(baseball_dt,lg) 
baseball_dt[J("NL")] 


## -------------------------
## mortality 
cohort[,sum(mortality == "Yes")/.N] 

## mortality by hospital ID (slower way)
cohort[,sum(mortality == "Yes")/.N,
       by=hosp_id][1:10] 

## For an even faster operation, use the key
## set key 
setkey(cohort,hosp_id) 
## mortality by hosp id, faster version of code
cohort[J(unique(hosp_id)),
       .(mortality_rate=sum(mortality == "Yes")/.N), 
       by=.EACHI][1:10]


## -------------------------
setkey(cohort,hosp_id) 
res1 <-  
  cohort[,list(mort_rate=sum(mortality == "Yes")/.N), 
         by=hosp_id] 
setorder(res1,mort_rate) 
res1[,barplot(mort_rate)] 


## -------------------------
## sort by hospital id then age 
setkey(cohort,hosp_id,age) 
## join all the rows in hospitals one to three 

cohort[J(c(1,2,3))] 
## join only to the first row 
## youngest person per hospital 
cohort[J(c(1,2,3)), mult="first"] 
## join only to the last row 
## oldest person per hospital 
cohort[J(c(1,2,3)),mult="last"] 


## -------------------------
## read in hospital traits for example joins 
hosp <- fread("hosp_demo.csv") 
## set keys for both tables (these are the things we will merge on) 
setkey(hosp,hosp_id) 
setkey(cohort,hosp_id) 
 
## right join: all the hospitals and whatever patients match 
cohort[hosp] 
## left join: all the patients and whatever hospitals match 
hosp[cohort] 
## inner join: only the overlapping hospitals and patients 
hosp[cohort,nomatch=0] 
## Full join (all patients and hospitals, even if they don't match) 
merge(hosp,cohort,all=TRUE) 

