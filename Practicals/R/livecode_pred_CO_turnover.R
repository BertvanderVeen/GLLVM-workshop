library(gllvm)
data(spider, package = "mvabund")
model<-gllvm(spider$abund[,c(4,5,(1:12)[-c(4,5)])], X= scale(spider$x),num.lv.c=2,randomB="LV",family="negative.binomial",quadratic=TRUE, n.init = 100,n.init.max=10,trace=TRUE)

newReflection = seq(-2,2,length.out=100)
fit <- predict(model,newX=data.frame(soil.dry=0,bare.sand=0,fallen.leaves=0,moss=0,herb.layer=0,reflection=newReflection),newLV=matrix(0,ncol=2,nrow=100),  type = "response")
plot(fit[,1],x=newReflection,type="l",ylab="Predicted abundance",xlab="Reflection")

d <- coef(model,"Cancoef")[6,]%*%diag(model$params$theta[1,3:4])%*%t(coef(model,"Cancoef")[6,,drop=FALSE])
tol <-  1/sqrt(-2*d)
2*qnorm(.999, sd = tol)
