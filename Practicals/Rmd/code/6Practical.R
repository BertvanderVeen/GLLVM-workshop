# quadratic

Y <- read.table("../data/waddenY.csv", sep="," ,header=TRUE, row.names = 2)[,-1]
X <- read.table("../data/waddenX.csv", sep="," ,header=TRUE, row.names = 2)[,-1]
# the temperature covariate has some NAs: I need to remove those rows before fitting models
Y <- subset(Y, !is.na(X$temperature))
X <- subset(X, !is.na(X$temperature))
# some species now lack any observations
Y <- Y[,colSums(Y)>0]
# standardising the covariates
X <- data.frame(lapply(X, function(x)if(is.numeric(x)){scale(x)}else{as.factor(x)}))

# TOC: total organic carbon
# DIN: Nitrogen
colnames(X)

model1 <- gllvm(y = Y, X = X, row.eff = ~(1|island), num.RR = 2, 
            lv.formula = ~ elevation + temperature + DIN + TOC + silt_clay + season, 
            family = "negative.binomial")

# This is the additional identifiability constraint implemented
t(coef(model1, "Cancoef"))%*%coef(model1, "Cancoef")

row.names(model1$lv.X) <- ...
row.names(model1$lv.X.design) <- paste0("Site", 1:nrow(Y))

library(grDevices)
ele <- X$elevation
rbPal <- colorRampPalette(c('green', 'yellow'))
cols <- rbPal(20)[as.numeric(cut(ele, breaks = 20))]

# do some fun customization in the ordiplot function
ordiplot(model1, 
         symbols = TRUE, 
         arrow.ci = FALSE, 
         s.cex = X$temperature+abs(min(X$temperature))+0.1, 
         s.colors = cols, pch = as.integer(X$season))

model2 <- gllvm(y = Y, X = X, row.eff = ~(1|island), num.RR = 2, randomB="LV",
                lv.formula = ~ elevation + temperature + DIN + TOC + silt_clay + season, 
                family = "negative.binomial", starting.val="zero")

# do some fun customization in the ordiplot function
ordiplot(model2, 
         symbols = TRUE, 
         arrow.ci = FALSE, 
         s.cex = X$temperature+abs(min(X$temperature))+0.1, 
         s.colors = cols, pch = as.integer(X$season))

model3 <- gllvm(y = Y, X = X, row.eff = ~(1|island), num.lv.c = 2, randomB="LV",
                lv.formula = ~ elevation + temperature + DIN + TOC + silt_clay + season, 
                family = "negative.binomial", starting.val="res", n.init=3)

AIC(model2, model3) # constrained is better
anova(model2, model3) # LRT also says constrained is better

# do some fun customization in the ordiplot function
ordiplot(model3, 
         symbols = TRUE, 
         arrow.ci = FALSE, 
         s.cex = X$temperature+abs(min(X$temperature))+0.1, 
         s.colors = cols, pch = as.integer(X$season))

# create correlation plot
corrplot::corrplot(getResidualCor(model3), type="lower", order="AOE", tl.cex = 0.3)

# create correlation plot due to covariates: only in devel version
corrplot::corrplot(getEnvironCor(model2), type="lower", order="AOE", tl.cex = 0.3)

source("3Wednesday/ordiGG.R")
library(ggplot2)
ggord(model2, , type  = "marginal",veccol = "red", vec_ext = 10, labcol = "red", ext = 1.3)+
  theme_bw()+ylim(c(-5,5))

# Fit unimodal model
model4 <- gllvm(y = Y, X = X, row.eff = ~(1|island), num.RR = 2, randomB="LV",
                lv.formula = ~ elevation + temperature + DIN + TOC + silt_clay + season, 
                family = "negative.binomial", quadratic="LV", n.init = 10, n.init.max = 3, trace  = TRUE)
AIC(model2,model4)


model4 <- gllvm(y = Y, X = X, row.eff = ~(1|island), num.RR = 2, randomB="LV",
                lv.formula = ~ elevation + temperature + DIN + TOC + silt_clay + season, 
                family = "negative.binomial", quadratic="LV", n.init = 10, n.init.max = 3, trace  = TRUE)
model4a <- gllvm(y = Y, X = X, row.eff = ~(1|island), num.RR = 1, randomB="LV",
                lv.formula = ~ elevation + temperature + DIN + TOC + silt_clay + season, 
                family = "negative.binomial", quadratic="LV", n.init = 10, n.init.max = 3, trace  = TRUE)
