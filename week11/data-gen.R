## generate data
no.obs <- 100
generate_data <- function(sz){
  set.seed(30)
  X1 <- rnorm(sz, mean = 120, sd = 23)
  X2 <- rgamma(sz, shape = 23, scale = 5)
  X3 <- rbinom(sz, size = sz*.1, prob = .8)
  X4 <- runif(sz, min = -2000, max = 30000)
  Y <- 2.3*X1 + X2^3.4 + X3 + X4 + X3*(.4*X4) + rnorm(sz, mean = 100, sd = 23)
  return(data.frame(X1, X2, X3, X4, Y))
}
df <- generate_data(100)
summary(df)
