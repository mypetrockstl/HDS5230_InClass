## -------------------------
library(data.table) 

## Import Data
cohort <- fread("patient_demo.csv") 
hosp <- fread("hosp_demo.csv") 


## ---------------------------------
## merge in the academic trait
setkey(cohort,hosp_id)
setkey(hosp,hosp_id)
cohort[hosp,academic := academic]
cohort


## ---------------------------------
dt1_wide <- 
  data.table('patient_id' = c(100,101,102),
             'survey_baseline' = c(2,5,3),
             'survey_6mos' = c(4,6,4),
             'survey_12mos' = c(3,NA,3))
dt1_wide


## ---------------------------------
# go from 'wide' to 'long' by 'melting' the dataframe
dt1_long <-
  melt(dt1_wide,
       id.vars = 'patient_id',
       variable.name = 'survey_time',
       value.name = 'survey_Score')
dt1_long
# remove the missing element
dt1_long <-
  dt1_long[!is.na(survey_Score)]
dt1_long


## ---------------------------------
# go from long to wide
# notice the missing data element was inferred!
dcast(dt1_long,
      formula = patient_id ~survey_time,
      value.var = 'survey_Score')


## ---------------------------------
## Calculate overall mortality rate
cohort[,list(mortality_rate=sum(mortality=='Yes')/.N)]
## Calculate mortality rate by hospital and gender
mortality_Rate_by_hosp <- 
  cohort[,list(mortality_rate=sum(mortality=='Yes')/.N),
         by=list(gender,hosp_id)]
mortality_Rate_by_hosp
## dcast to prettier format
dcast(mortality_Rate_by_hosp,hosp_id ~ gender)


## ---------------------------------
## remove the hospital data
rm(hosp)
## check tables 
tables()

