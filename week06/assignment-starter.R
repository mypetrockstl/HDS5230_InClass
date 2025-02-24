library(data.table)
library(geosphere)
library(rgdal)
library(GA)
library(purrr)

## Load the population data
pop.data <- data.table::fread("Mo_pop_Sim.csv")
str(pop.data)
frac <- 0.0001
small.data <- pop.data[sample(1:nrow(pop.data),
                               size = round(nrow(pop.data) * frac),
                               replace = F), ## extract a sample of randomlychosen 1% rows
                        ]  ## and choose all columns

## Load the FQHC data
data_path <- 'MO_2018_Federally_Qualified_Health_Center_Locations'
fqhc.data <- data.table(as.data.frame(readOGR(data_path,
                     'MO_2018_Federally_Qualified_Health_Center_Locations')))

str(fqhc.data)
## Select a subset of 4 rows, drawn at random, and cols: OBJECTID, Long, Lat
set.seed(8888)
no.ctrs <-  8
no.needed <- 2
sites.dt <- fqhc.data[sample(1:nrow(fqhc.data), no.ctrs, replace = F),
                      list(OBJECTID = as.character(OBJECTID),
                           Longitude,
                           Latitude)]



## Create combinations of residences and centers
small.data <- cbind(small.data, resid = c(1:nrow(small.data)))
setkey(small.data, resid)

dist.dt <- data.table(CJ(as.character(small.data$resid),
                         as.character(sites.dt$OBJECTID)))
names(dist.dt)
setnames(dist.dt, c("V1", "V2"), c("resid", "OBJECTID"))
str(dist.dt)
dist.dt

## Compute distances on a small subset of values - this takes a long time
# if run on all rows in the dataset
v <- map_dbl(1:nrow(dist.dt),
        function(rid){
          r.rsd <- small.data[resid == dist.dt[rid,resid]]
          r.fqhc <- fqhc.data[OBJECTID == as.character(dist.dt[rid,OBJECTID])]

          distm(c(r.rsd$long, r.rsd$lat),
                c(r.fqhc$Longitude, r.fqhc$Latitude),
                fun = distHaversine)

          ## note that the above distance is in meters
          ## convert it to miles
        })

dist.dt[, distance := v]

## Next, use the distance information to make decisions on, let's say top 2 centers
## The function combn() produces all possible combinations of elements in x, taking m at a time
## If we want to take all possible combinations of 2 items, out of a set of 4...
## combn(4, 2)
## the combinations are in columns; a simpler-to-read format is to show them in rows
## t(combn(x=1:4,m = 2)) ## transpose the results using t()

## If we want to identify the two best centers, out of four, for providing the extended services
## we need identify the two best ones based on, say, the total average distance between each of them
## and each residence in our sample.
unique(sites.dt$OBJECTID)
## Build combinations
combinations <- data.table(as.data.frame(t(combn(unique(sites.dt$OBJECTID), no.needed))))
combinations
names(combinations) <- map_chr(1:no.needed,
                               function(x){
                                 paste0("loc",x)
                               })
#names(combinations) <- c("loc1", "loc2")
##
meandists <- dist.dt[, mean(distance), by=OBJECTID]
ind = 1

get_combined_distance <- function(loc1, loc2, ctr.id){

}
map_dbl(1:nrow(combinations),
        function(ind){
          mean(c(meandists[meandists$OBJECTID == combinations[ind,loc1]]$V1,
                 meandists[meandists$OBJECTID == combinations[ind,loc2]]$V1))
        })

combinations[, meandist :=
               map_dbl(1:nrow(combinations),
                       function(ind){
                         mean(c(meandists[meandists$OBJECTID == combinations[ind,loc1]]$V1,
                                meandists[meandists$OBJECTID == combinations[ind,loc2]]$V1))
                       })]
## Find the best one - this is the brute-force approach
combinations[meandist == min(combinations$meandist)]

## Next, implement the GA-based approach for finding a solution and cross-check
## it against the solution found above.
## dist.dt is a datatable that has distances between each residence and each FQHC
# fit.fn <- function(loc1, loc2, ...){
#   ## for a given combination of FQHC locations, return the mean from all
#   ## residences
#   # loc1 = 119
#   # loc2 = 193
#   1/((mean(dist.dt[OBJECTID == loc1, distance]) +
#       mean(dist.dt[OBJECTID == loc2, distance]))/2)
#
# }
# combinations <- data.table(as.data.frame(t(combn(unique(sites.dt$OBJECTID), 2))))
# names(combinations) <- c("loc1", "loc2")
# ga(type = "permutation",
#    fitness = fit.fn,
#    combinations,
#    lower = 1,
#    upper = 6
#    )

## treat the problem as a knapsack problem, where your goal is to identify that combination of
## FQHCs that result in the smallest aggregated combined distance from all residences.
# library(GA)
# p <- c(6,5,8,9,6,7,3)
# w <- c(2,3,6,7,5,9,4)
# W <- 9
# knapsack <- function(x){
#   f <- sum(x*p)
#   penalty <- sum(w) * abs(sum(x*w) - W)
#   f - penalty
# }
#
# gamodel <- ga(type = "binary",
#               fitness = knapsack,
#               nBits = length(w),
#               maxiter = 1000,
#               run = 200,
#               popSize = 20)
# gamodel
# summary(gamodel)

p <- rep(1, length(unique(dist.dt$OBJECTID)))
w <- dist.dt[,mean(distance), by = OBJECTID]$V1
w <- w/max(w)
W <- max(w) * 1.2#1.25
knapsack <- function(x){
  f <- sum(x*p)
  penalty <- sum(w) * abs(sum(x*w) - W)
  (f - penalty)

}
gamodel <- ga(type = "binary",
              fitness = knapsack,
              nBits = length(w))
summary(gamodel)
unique(dist.dt$OBJECTID)

