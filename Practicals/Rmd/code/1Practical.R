Y <- read.table("data/waddenY.csv", sep="," ,header=TRUE, row.names = 2)[,-1]
X <- read.table("data/waddenX.csv", sep=",", header=TRUE, row.names = 2)[,-1]

library(mvabund)
# fit a model for count data
model <- manyglm(mvabund(Y)~elevation+temperature+silt_clay, 
                 family = "poisson", data = X)

# look at the coefficients
coefplot(model)  # very large uncertainties for some parameters

# Taking a look at how many observatins we have for each species
colSums(ifelse(Y==0,0,1)) # Some of these are 1..

# Exclude species with too few observations
Y2 <- Y[,colSums(ifelse(Y==0,0,1))>4]

# Refit the model
model1 <- manyglm(mvabund(Y2)~elevation+temperature+silt_clay, 
                 family = "poisson", data = X)
coefplot(model1)

# Checking residuals
plot(model1)

# plot residuals against species
ds <- residuals(model1)
ds[is.infinite(ds)] <- 0

plot(NA, ylim = range(ds), xlim = c(1,ncol(Y2)), type="n",xlab="Species",ylab="DS residuals")
for(j in 1:ncol(Y2)){
  points(rep(j, nrow(ds)), ds[,j], col = j)
}

# Fit NB instead, there is overdispersion
model2 <- manyglm(mvabund(Y2)~elevation+temperature+silt_clay, 
                  family = "negative.binomial", data = X, cor.type = "R")

# plot residuals against species
ds <- residuals(model2)
ds[is.infinite(ds)] <- 0
plot(NA, ylim = range(ds), xlim = c(1,ncol(Y2)), type="n",xlab="Species",ylab="DS residuals")
for(j in 1:ncol(Y2)){
  points(rep(j, nrow(ds)), ds[,j], col = j)
}

# new residual plots; these look much better
plot(model2, which=1)
plot(model2, which=2)

coefplot(model2)

# hypothesis testing
anova(model2, cor.type = "R")
