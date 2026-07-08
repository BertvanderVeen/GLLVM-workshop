# Auto-generated from Practicals/Rmd/9Practical.Rmd via knitr::purl(). Do not edit directly -- re-run after editing the Rmd. See Practicals/R/README.md.

Y <- read.table("../../data/waddenY.csv", sep="," ,header=TRUE, row.names = 2)[,-1]

library(gllvm)
TMB::openmp(parallel::detectCores()-1, autopar = TRUE, DLL = "gllvm")
model1 <- gllvm(Y, num.lv = 2, quadratic = TRUE, n.init = 3, family = "negative.binomial", disp.formula = rep(1, ncol(Y)))
gllvm::ordiplot(model1, biplot = TRUE)

library(gllvm)
ordiplot(model1, biplot = TRUE)

optima(model1, sd.errors = FALSE)

tolerances(model1, sd.errors = FALSE)

par(mfrow=c(2,1))
LVs = getLV(model1)
newLV = cbind(LV1 = seq(min(LVs[,1]), max(LVs[,1]), length.out=1000), LV2 = 0)
preds <- predict(model1, type = "response", newLV = newLV)
plot(NA, ylim = range(preds), xlim = c(range(getLV(model1))), ylab  = "Predicted response", xlab = "LV1")
segments(x0=optima(model1, sd.errors = FALSE)[,1],x1 = optima(model1, sd.errors = FALSE)[,1], y0 = rep(0, ncol(model1$y)), y1 = apply(preds,2,max), col = "red", lty = "dashed", lwd = 2)
rug(getLV(model1)[,1])
sapply(1:ncol(model1$y), function(j)lines(sort(newLV[,1]), preds[order(newLV[,1]),j], lwd = 2))

newLV = cbind(LV1 = 0, LV2 =  seq(min(LVs[,2]), max(LVs[,2]), length.out=1000))
preds <- predict(model1, type = "response", newLV = newLV)
plot(NA, ylim = range(preds), xlim = c(range(getLV(model1))), ylab  = "Predicted response", xlab = "LV2")
segments(x0=optima(model1, sd.errors = FALSE)[,2],x1 = optima(model1, sd.errors = FALSE)[,2], y0 = rep(0, ncol(model1$y)), y1 = apply(preds,2,max), col = "red", lty = "dashed", lwd = 2)
rug(getLV(model1)[,2])
sapply(1:ncol(model1$y), function(j)lines(sort(newLV[,2]), preds[order(newLV[,2]),j], lwd = 2))

# Extract tolerances
tol <- tolerances(model1, sd.errors = FALSE)
gradLength <- 4/apply(tol, 2, median)

cat("Gradient length:", gradLength)

model2<-update(model1, num.lv=1)
AIC(model1, model2)
BIC(model1, model2)

turn <- 2*qnorm(.999, sd = apply(tol, 2, median))
cat("Turnover rate:", turn)
