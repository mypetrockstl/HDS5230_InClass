###################################################################
## Pandas Data Cleaning and Dtypes 
## Author: Evan Carey
###################################################################

## import libraries
import numpy as np
import pandas as pd
import matplotlib as plt

## Print more columns by changing the max columns
pd.set_option('max_columns', 16)
## only print 10 rows
pd.set_option('max_rows', 16)

## import dataset
patient_data = \
    pd.read_csv(r'C:\Users\evancarey\Dropbox\Work\SLU\Courses\data\ex_dm_person_demo.csv')

## Examine dataset
patient_data.shape
patient_data.head()
patient_data.tail()
patient_data.dtypes

## Perform type conversions
## change p_id to object
patient_data['p_id'] = \
    patient_data['p_id'].astype('object')

## change gender to be categorical
patient_data['Gender'].astype('category')
patient_data['Gender_cat'] = \
    patient_data['Gender'].astype('category',categories=['Male','Female'])
patient_data['Gender_cat'].value_counts(dropna=False)

## What about the Education variable?
patient_data['Education']\
    .value_counts(dropna=False)
## looks good
patient_data['Education']\
    .str.lower()\
    .value_counts(dropna=False)
## convert to category
patient_data['Education_cat'] = \
    patient_data['Education']\
    .str.lower()\
    .astype('category',
            ordered = True,
            categories=['high school','college','graduate degree'])
## check new variable
patient_data['Education_cat'].value_counts() # right order

## Investigate age 
patient_data['Age']
patient_data['Age'].describe()
patient_data['Age'].hist(bins=40)

## Weird cluster of implausible ages?
## Set to missing
patient_data.loc[patient_data['Age'] > 110,
                 'Age'] = np.NaN
## check my ages
patient_data['Age'].describe()
patient_data['Age'].hist(bins=40)

##  Check income?
patient_data['Income'].describe()
patient_data['Income'].hist(bins=40) # looks reasonable

## Convert the date variable - it is month-day-year
patient_data['Baseline_date_dt'] = \
    pd.to_datetime(patient_data['Baseline_date'])

## check conversion - looks good!
patient_data[['Baseline_date_dt','Baseline_date']]

## more on dates - extract parts of date like year
patient_data['Baseline_date_year'] = \
    patient_data['Baseline_date_dt'].dt.year

patient_data
