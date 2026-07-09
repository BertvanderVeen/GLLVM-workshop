library(gllvm)
data(spider,package="mvabund")
model <- gllvm(spider$abund, X= scale(spider$x), lv.formula = ~fallen.leaves+moss, num.RR=2,family="poisson")
ordiplot(model)

newn = 100
newMoss <- seq(min(spider$x$moss), max(spider$x$moss), length.out=newn)
fit <- predict(model, newX = data.frame(fallen.leaves = 0, moss = newMoss), type="response", se.fit = TRUE)

spp = 12
par(mfrow=c(1,3))

plot(y = fit$fit[,spp], x = newMoss, type = "l", ylab = "Predicted abundance", xlab = "Moss")
lines(y = fit$lower[,spp], x = newMoss, col = "red", lty = "dashed")
lines(y = fit$upper[,spp], x = newMoss, col = "red", lty = "dashed")

# this one's a bit messy
plot(y = gllvm:::gllvm.presence.prob(fit = fit$fit, object = model, spp = spp), x = newMoss, type = "l", ylab = "Predicted presence", xlab = "Moss")

simfit <- predict(model, newX = data.frame(fallen.leaves = 0, moss = newMoss), type="response", se.fit = TRUE,  alpha = NULL)

R = 1e3
sim <- matrix(NA, nrow = newn, ncol = R)
for(i in 1:R){
  sim[,i] <- gllvm:::gllvm.presence.prob(fit = as.matrix(simfit$ci.sim[i,,spp]), object = model, spp = spp)
}
simCI <- t(apply(sim, 1, quantile, c(0.025,0.975)))
lines(simCI[,1], x = newMoss, col = "red", lty = "dashed")
lines(simCI[,2], x = newMoss, col = "red", lty = "dashed")

sr = predictSR(model, newX = data.frame(fallen.leaves = 0, moss = newMoss))
plot(y = sr$expected$fit, x = newMoss, type = "l", ylab = "Predicted richness", xlab = "Moss")
lines(y = sr$expected$lower, x = newMoss, col = "red", lty = "dashed")
lines(y = sr$expected$upper, x = newMoss, col = "red", lty = "dashed")
