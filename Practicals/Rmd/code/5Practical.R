Y <- read.table("data/waddenY.csv", sep="," ,header=TRUE, row.names = 2)[,-1]

library(gllvm)
model1 <- gllvm(Y, num.lv = 2, family = "poisson", quadratic = "LV", n.init = 3, sd.errors = FALSE, trace = TRUE)
optima(model1, sd.errors=FALSE)
tolerances(model1, sd.errors=FALSE)
ordiplot(model1, symbols = TRUE, biplot = TRUE, spp.arrows = FALSE)

# Let's plot the predicted curves!
LVs = getLV(model1)
newLV = cbind(LV1 = seq(min(LVs[,1]), max(LVs[,1]), length.out=1000), LV2 = 0)
preds <- predict(model1, type = "response", newLV = newLV)
plot(NA, ylim = range(preds), xlim = c(range(getLV(model1))), ylab  = "Predicted response", xlab = "LV1")
segments(x0=optima(model1, sd.errors = FALSE)[,1],x1 = optima(model1, sd.errors = FALSE)[,1], y0 = rep(0, ncol(model1$y)), y1 = apply(preds,2,max), col = "red", lty = "dashed", lwd = 2)
rug(getLV(model1)[,1])
sapply(1:ncol(model1$y), function(j)lines(sort(newLV[,1]), preds[order(newLV[,1]),j], lwd = 2))

newLV = cbind(LV1 = 0, LV2 =  seq(min(LVs[,2]), max(LVs[,2]), length.out=1000))
preds <- predict(model1, type = "response", newLV = newLV)
plot(NA, ylim = c(min(preds), 400), xlim = c(range(getLV(model1))), ylab  = "Predicted response", xlab = "LV2")
segments(x0=optima(model1, sd.errors = FALSE)[,2],x1 = optima(model1, sd.errors = FALSE)[,2], y0 = rep(0, ncol(model1$y)), y1 = apply(preds,2,max), col = "red", lty = "dashed", lwd = 2)
rug(getLV(model1)[,2])
sapply(1:ncol(model1$y), function(j)lines(sort(newLV[,2]), preds[order(newLV[,2]),j], lwd = 2))

# we really need to adjust this model: NB

Y2 <- Y[,colSums(ifelse(Y==0,0,1))>4]

model2 <- gllvm(Y2, num.lv = 2, family = "negative.binomial", quadratic = "LV", n.init = 3, sd.errors = FALSE, trace = TRUE)
ordiplot(model2, biplot=TRUE, s.colors = "grey")
optima(model2, sd.errors=FALSE)
tolerances(model2, sd.errors=FALSE)

LVs = getLV(model2)
newLV = cbind(LV1 = seq(min(LVs[,1]), max(LVs[,1]), length.out=1000), LV2 = 0)
preds <- predict(model2, type = "response", newLV = newLV)
plot(NA, ylim = range(preds), xlim = c(range(getLV(model2))), ylab  = "Predicted response", xlab = "LV1")
segments(x0=optima(model2, sd.errors = FALSE)[,1],x1 = optima(model2, sd.errors = FALSE)[,1], y0 = rep(0, ncol(model2$y)), y1 = apply(preds,2,max), col = "red", lty = "dashed", lwd = 2)
rug(getLV(model2)[,1])
sapply(1:ncol(model2$y), function(j)lines(sort(newLV[,1]), preds[order(newLV[,1]),j], lwd = 2))

newLV = cbind(LV1 = 0, LV2 =  seq(min(LVs[,2]), max(LVs[,2]), length.out=1000))
preds <- predict(model2, type = "response", newLV = newLV)
plot(NA, ylim = c(min(preds), 400), xlim = c(range(getLV(model2))), ylab  = "Predicted response", xlab = "LV2")
segments(x0=optima(model2, sd.errors = FALSE)[,2],x1 = optima(model2, sd.errors = FALSE)[,2], y0 = rep(0, ncol(model2$y)), y1 = apply(preds,2,max), col = "red", lty = "dashed", lwd = 2)
rug(getLV(model2)[,2])
sapply(1:ncol(model2$y), function(j)lines(sort(newLV[,2]), preds[order(newLV[,2]),j], lwd = 2))

# Have a look at the tolerances, gradient length, and turnover
# We see: one long gradient (LV1) one short (LV2)
tol <- tolerances(model2, sd.errors = FALSE)
gradLength <- 4/apply(tol, 2, median)
turn <- 2*qnorm(.999, sd = apply(tol, 2, median))

# Fit equal tolerances model
model3 <- gllvm(Y2, num.lv = 2, family = "negative.binomial", row.eff="random", sd.errors=FALSE)

# compare LVs common and equal tolerances models
vegan::procrustes(getLV(model2), getLV(model3), symmetric = TRUE)
AIC(model2, model3)
anova(model2, model3)

par(mfrow=c(1,2))
ordiplot(model3, symbols=TRUE, main="Common")
ordiplot(model2, symbols=TRUE, main="Equal")