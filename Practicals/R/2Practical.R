# Auto-generated from Practicals/Rmd/2Practical.Rmd via knitr::purl(). Do not edit directly -- re-run after editing the Rmd. See Practicals/R/README.md.

Y <- read.table("../../data/waddenY.csv", sep="," ,header=TRUE, row.names = 2)[,-1]
X <- read.table("../../data/waddenX.csv", sep=",", header=TRUE, row.names = 2)[,-1]
X <- X[,-which(apply(X,2, anyNA))] # remove column with NAs

library(gllvm)
model1 <- gllvm(Y, X, formula = ~scale(silt_clay) + scale(elevation), family = "negative.binomial", num.lv = 0)
coefplot(model1)

model2 <- gllvm(Y, X, formula = ~(0+scale(silt_clay)|1) + (0+scale(elevation)|1), family = "negative.binomial", num.lv = 0)
randomCoefplot(model2)

summary(model2)

model3 <- gllvm(Y, X, formula = ~(0+scale(silt_clay)|1) + (0+scale(elevation)|1), row.eff =~1, family = "negative.binomial", num.lv = 0)
summary(model3)
randomCoefplot(model3)

AIC(model2, model3)

model4 <- gllvm(Y, X, formula = ~diag(0+island|1) + (0+scale(silt_clay)|1) + (0+scale(elevation)|1), row.eff =~1, family = "negative.binomial", num.lv = 0)
model5 <- gllvm(Y, X, studyDesign = X, row.eff = ~ (1|island), formula = ~(0+scale(silt_clay)|1) + (0+scale(elevation)|1), family = "negative.binomial", num.lv = 0)

AIC(model4, model5)

model6 <- gllvm(Y, X, formula = ~diag(0+island|1) + scale(silt_clay) + scale(elevation), row.eff =~1, family = "negative.binomial", num.lv = 0)

xnew <- seq(min(scale(X$elevation)), max(scale(X$elevation)), length.out = 100)
std <- sqrt(diag(model4$params$sigmaB)[5])
alphadiv <- (xnew*std*sd(X$elevation)+mean(X$elevation)*std)^2
xnew <- xnew*sd(X$elevation)+mean(X$elevation)
plot(xnew, alphadiv, type = "l") # backtransform

model8 <- gllvm(Y, X, formula = ~diag(0+island|1) + (0+scale(silt_clay)+scale(elevation)|1), row.eff =~1, family = "negative.binomial", num.lv = 0)
summary(model8)

randomCoefplot(model8, which.Xcoef = c("scale.silt_clay.", "scale.elevation."))

model9 <- gllvm(Y, X, formula = ~(0+island+scale(silt_clay)+scale(elevation)|1), row.eff =~1, family = "negative.binomial", num.lv = 0)

model9 <- gllvm(Y, X, formula = ~(0+island+scale(silt_clay)+scale(elevation)|1), row.eff =~1, family = "negative.binomial", num.lv = 0, control = list(maxit = 10e3))
summary(model9)
cors <- cov2cor(model9$params$sigmaB)
colnames(cors) <- row.names(cors) <- colnames(model9$params$sigmaB)
corrplot::corrplot(cors, type = "lower", diag = FALSE)

plot(X$silt_clay, X$elevation)

sigmaB <- diag(model4$params$sigmaB)
names(sigmaB) <- colnames(model4$params$sigmaB)
sigmaB / sum(sigmaB)

head(X[,1:4], 12)

StudyDesign <- data.frame(X[,1:4], sample = rownames(X))
model10 <- gllvm(Y, X, formula = ~(0+scale(silt_clay)|1) + (0+scale(elevation)|1),
                 studyDesign = StudyDesign,
                 row.eff = ~(1|island:transect) + (1|island:transect:station) + (1|sample) + island + season,
                 family = "negative.binomial", num.lv = 0)

summary(model10)

model10$params$sigma
confint(model10, parm = "sigma")

model_pois <- gllvm(Y, X, formula = ~scale(silt_clay) + scale(elevation), family = "poisson", num.lv = 0)
plot(model_pois, which = c(1, 2))

plot(model1, which = c(1, 2))

qqnorm(as.vector(model2$params$Br))
qqline(as.vector(model2$params$Br))
