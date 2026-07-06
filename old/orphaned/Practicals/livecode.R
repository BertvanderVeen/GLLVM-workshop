# livecoding: kelp or skabbholmen
load("Coolen.RData")
library(gllvm)
TMB::openmp(7, DLL="gllvm", autopar=TRUE)


model2 <- gllvm(Y, X, 
                formula = ~ SampleType + (scale(Depth)|1) + (scale(age)|1),
                row.eff = ~(1|PlatformID), studyDesign = X,
                family = "negative.binomial", num.lv = 0, sd.errors=TRUE, Ab.struct="diagonal", optim.method="L-BFGS-B")

model3 <- gllvm(y = Y, X = X, formula = ~diag(0+SampleType|1)+(0+scale(Depth) +I(scale(Depth)^2) | 1), family = "negative.binomial", num.lv = 0, 
                studyDesign = X, row.eff = ~(1 | PlatformID), sd.errors = FALSE, 
                Ab.struct = "diagonal", optim.method = "L-BFGS-B")
plot(model3)
qqnorm(coef(model3, "Br")[3,])
qqline(coef(model3, "Br")[3,])

data("Skabbholmen")
Y <- Skabbholmen$Y
X <- Skabbholmen$X

model <- gllvm(y = Y, X = X, studyDesign = X, 
   num.RR = 2,
   lv.formula = ~ scale(Elevation) + I(Year-1978),
   family = "ordinal",
   zeta.struc="common",
   row.eff=~(1|transectID))

modelb <- gllvm(y = Y, X = X, studyDesign = X, 
               num.RR = 2,
               lv.formula = ~ scale(Elevation) + I(Year-1978),
               family = "ordinal",
               zeta.struc="common",
               row.eff=~(1|transectID), starting.val = "zero")

model1 <- gllvm(y = Y, X = X, studyDesign = X, 
               formula = ~ scale(Elevation) + I(Year-1978),
               family = "ordinal",
               zeta.struc="common",
               row.eff=~(1|transectID), num.lv=0)

logLik(model)
logLik(model1)

coefplot(model1)

model2 <- gllvm(y = Y, X = X, studyDesign = X, 
               num.RR = 2,
               lv.formula = ~ (0+scale(Elevation)|1) + (0+I(Year-1978)|1),
               family = "ordinal",
               zeta.struc="common",
               row.eff=~(1|transectID),
               randomB = "LV")

ordiplot(model2, arrow.ci = FALSE, rotate= FALSE)

?getEnvironCor
?getEnvironCov
?getResidualCov
?getResidualCor

getEnvironCov(model2)$trace

covs <- getEnvironCov(model2)$cov+diag(ncol(model2$y))

cors <- cov2cor(covs)
corrplot::corrplot(cors,type="lower",diag=FALSE, order="AOE", tl.pos="l", tl.cex = 0.5)

# Fit model with quadratic option
model3 <- gllvm(y = Y, X = X, studyDesign = X, 
                num.RR = 2,
                lv.formula = ~ (0+scale(Elevation)|1) + (0+I(Year-1978)|1),
                family = "ordinal",
                zeta.struc="common",
                row.eff=~(1|transectID),
                randomB = "LV", quadratic = "LV")

# Create plot of quadratic curve
### Predicting manually, bug in predict.gllvm ###
newX <- data.frame(Elevation = (seq(min(X$Elevation), max(X$Elevation), length.out = 100)-mean(X$Elevation))/sd(X$Elevation), Year = 0)
eta = matrix(model3$params$beta0, ncol = ncol(model3$y),byrow=TRUE,nrow=nrow(newX))
newLV = as.matrix(newX)%*%model3$params$LvXcoef
eta = eta + newLV%*%t(model3$params$theta[,1:2])+(newLV^2)%*%t(model3$params$theta[,-c(1:2)])
preds = pnorm(model3$params$zeta[2]-eta)-pnorm(model3$params$zeta[1]-eta)
#################################################
plot(NA, ylim = range(preds), xlim = range(scale(X$Elevation)), ylab  = "Predicted response", xlab = "Elevation")
rug(scale(X$Elevation))
sapply(1:ncol(model3$y), function(j)lines(sort(newX[,1]), preds[order(newX[,1]),j], lwd = 2))
