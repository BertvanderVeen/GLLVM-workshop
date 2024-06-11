Y <- read.table("data/waddenY.csv", sep="," ,header=TRUE, row.names = 2)[,-1]

# remove species with few observations
Y2 <- Y[,colSums(ifelse(Y == 0,0,1))>4]

library(gllvm)
# If we want to parallelize model fitting
# Might not work with current CRAN version of gllvm
TMB::openmp(detectCores()-1, autopar=TRUE) 

model <- gllvm(Y2, num.lv = 2, family = "poisson", sd.errors = FALSE)
sdErr <- se(model)
model$sd <-sdErr$sd
model$Hess <- sdErr$Hess

# Retrieve confidence intervals
confint(model)

# ONLY in devel version currently: plotting the summary object
plot(summary(model, spp.intercepts = TRUE))

# ?vegan::ordiplot # note: gllvm ordiplot can clash with vegan ordiplot
par(mfrow=c(1,2))
ordiplot(model, biplot = TRUE, symbols = TRUE, predict.region = TRUE, col.ellips = "grey")
ordiplot(model, biplot = TRUE, symbols = TRUE, predict.region = TRUE, col.ellips = "grey", rotate = FALSE)

par(mfrow=c(1,1))
X <- read.table("data/waddenX.csv", sep="," ,header=TRUE, row.names = 2)[,-1]
ordiplot(model, symbols = TRUE, predict.region = TRUE, col.ellips = as.factor(X$season), s.colors = as.factor(X$season), 
         pch = 16, 
         ylim=c(-6,5))

# correlation plot
library(corrplot)
corrplot(getResidualCor(model), type = "lower")
corrplot(getResidualCor(model), type = "lower", order="AOE")

# relative variance
getResidualCov(model)$var.q/sum(getResidualCov(model)$var.q)

LVs <- getLV(model)
Loadings <- getLoadings(model) # only in devel version
Loadings <- model$params$theta%*%diag(model$params$sigma.lv)
colnames(Loadings) <- c("LV1", "LV2")

do_svd <- svd(LVs) # rotation
rotation <- do_svd$v
scales <- sapply(1:ncol(LVs), function(q)sqrt(sum(LVs[,q]^2))*sqrt(sum(Loadings[,q]^2)))
newLVs <- apply(LVs,2,function(x)x/sqrt(sum(x^2))*scales^0.5)
newRotatedLVs <- newLVs%*%do_svd$v
newLoadings <- apply(Loadings,2,function(x)x/sqrt(sum(x^2))*scales^0.5)
newRotatedLoadings <- Loadings%*%do_svd$v

library(ggplot2)
p2 <- ggplot()+geom_text(data=LVs, aes(y=LV2,x=LV1, label = 1:nrow(Y2)), col = "grey")+
  geom_text(data=Loadings, aes(y = LV2, x = LV1, label = colnames(Y2), col = "blue"))+
  theme_bw()+coord_fixed()+ guides(col="none")
p2

model2 <- update(model, family = "negative.binomial")
plot(model2)

ordiplot(model2, biplot = TRUE, symbols=TRUE)

model2 <- update(model2, row.eff=~(1|island/station/transect), studyDesign = X)

# try a model with 3 LVs
model3 <- update(model2, num.lv = 3)

# Check which is "best" by AIC
AIC(model2,model3)