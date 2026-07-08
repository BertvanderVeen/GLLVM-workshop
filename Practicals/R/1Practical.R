# Auto-generated from Practicals/Rmd/1Practical.Rmd via knitr::purl(). Do not edit directly -- re-run after editing the Rmd. See Practicals/R/README.md.

Y <- read.table("../../data/waddenY.csv", sep="," ,header=TRUE, row.names = 2)[,-1]
X <- read.table("../../data/waddenX.csv", sep=",", header=TRUE, row.names = 2)[,-1]

library(mvabund)
require(graphics)
meanvar.plot(mvabund(Y), xlab = "mean", ylab="var")

plot(apply(Y,2,var)~colMeans(Y),log="xy", ylab = "Variance (log scale)", xlab="Mean (log scale)")

lm(log(apply(Y,2,var))~log(colMeans(Y)))

matplot(sort(X$silt_clay),pmax(Y[order(X$silt_clay),], 1), type  ="p", log = "y", ylab = "Y (log scale)")
matplot(sort(X$elevation),pmax(Y[order(X$elevation),], 1), type  ="p", log = "y", ylab = "Y (log scale)")

data <- data.frame(Y, X)
datalong <- reshape(data, 
                    varying = colnames(Y), 
                    v.names = "count", 
                    idvar = "Site", 
                    timevar = "Species", 
                    direction = "long")

datalong$Species <- factor(datalong$Species, 
                           labels = colnames(Y))

model1 <- glm(count~silt_clay + elevation, data = datalong, family = "poisson")

summary(model1)

model2 <- glm(count~scale(silt_clay) + scale(elevation), data = datalong, family = "poisson")
summary(model2)

logLik(model1)
logLik(model2)

par(mar=c(5,7,4,2))
CIs <- confint(model2)
est <-  coef(model2)
plot(x = est, y = 1:length(est), xlab = "Estimate", ylab = NA, pch  = "x", xlim = range(CIs), yaxt = "n")
axis(2, 1:length(est), c("Intercept", labels(terms(model2))), las = 1)
segments(CIs[,"2.5 %"], 1:length(est), CIs[,"97.5 %"], 1:length(est))

model3 <- glm(count~ 0 + Species + scale(silt_clay):Species + scale(elevation):Species, data = datalong, family = "poisson")

table(colSums(ifelse(Y==0,0,1)))

model4 <- glm(count~Species + scale(silt_clay) + scale(elevation) + scale(silt_clay):Species + scale(elevation):Species, data = datalong, family = "poisson")

logLik(model3)
logLik(model4)

par(mar=c(5,7,4,2), mfrow = c(1, 3))
ses <- matrix(sqrt(diag(vcov(model3))), ncol = 3)
LI <- est + qnorm(1-0.975)*ses
UI <- est + qnorm(0.975)*ses
est <- matrix(coef(model3), ncol = 3)
for(i in 1:3){
plot(x = est[,i], y = 1:nrow(est), xlab = "Estimate", ylab = NA, pch  = "x", xlim = c(min(LI[,i]), max(UI[,i])), yaxt = "n", main = c("Intercept",  labels(terms(model2)))[i])
axis(2, 1:nrow(est), colnames(Y), las = 1)
segments(LI[,i], 1:nrow(est), UI[,i], 1:nrow(est))
}

GLMs <- list()
for(j in 1:ncol(Y)){
  GLMs[[j]] <- glm(Y[,j]~silt_clay + elevation, family = "poisson", data = X)
}
Reduce("+", lapply(GLMs, logLik))

X <- X[,-which(apply(X,2, anyNA))] # remove column with NAs
library(gllvm)
model5 <- gllvm(Y, X, formula = ~silt_clay + elevation, family = "poisson", num.lv = 0)
logLik(model5)
summary(model5, digits = 3L)

model6 <- gllvm(Y, studyDesign = X, row.eff = ~scale(silt_clay) + scale(elevation), family = "poisson", num.lv = 0)
summary(model6)

coefplot(model5, order = FALSE)

model7 <- gllvm(Y, X, formula = ~scale(silt_clay) + scale(elevation), family = "negative.binomial", num.lv = 0)
