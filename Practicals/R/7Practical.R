# Auto-generated from Practicals/Rmd/7Practical.Rmd via knitr::purl(). Do not edit directly -- re-run after editing the Rmd. See Practicals/R/README.md.

library(gllvm)
TMB::openmp(parallel::detectCores()-1, autopar = TRUE, DLL = "gllvm")

Y <- read.csv("../../data/roadY.csv")[,-1]
Y <- Y/100 # beta responses need to be in the range (0,1)
Y <- Y[, colSums(ifelse(Y == 0, 0, 1)) > 3]
X <- read.csv("../../data/roadX.csv")[,-1]
X$site <- as.factor(X$site)
X <- data.frame(lapply(X, function(x) if(is.numeric(x)){scale(x)}else{as.factor(x)}))
X$plot <- factor(ave(seq_along(X$site), X$site, FUN = seq_along))

zetaMap <- matrix(NA,nrow=2,ncol=ncol(Y))
zetaMap[1,] <- 1:ncol(Y) # lower cut-off
# upper cut-off
zetaMap[2,which(apply(Y,2,max)==1)] <- ncol(Y)+1 # collect for species that have 1
zetaMap[2,which(apply(Y,2,max)!=1)] <- NA # fix for species that do not have 1
setMap = list(zeta = factor(c(zetaMap)))

model1 <- gllvm(y = Y, X = X,
                lv.formula = ~dist_int_veg + caco + slope + loi + grain_size_stand_f + years_since_n + gf,
                num.RR = 2, family = "orderedBeta", disp.formula = rep(1, ncol(Y)), n.init = 3,
                zetacutoff = c(-2,20), setMap = setMap)
ordiplot(model1)

summary(model1)
plot(summary(model1))

coefplot(model1, which.Xcoef = "slope")

model2 <- gllvm(y = Y, X = X,
                lv.formula = ~dist_int_veg + caco + slope + loi + grain_size_stand_f + years_since_n + gf,
                num.RR = 2, row.eff = ~(1|site/plot), studyDesign = X,
                family = "orderedBeta", disp.formula = rep(1, ncol(Y)),
                zetacutoff = c(-2,20), setMap = setMap)

model3 <- gllvm(y = Y, X = X,
                lv.formula = ~dist_int_veg + caco + slope + loi + grain_size_stand_f + years_since_n + gf,
                num.lv.c = 2, row.eff = ~(1|site/plot), studyDesign = X,
                family = "orderedBeta", disp.formula = rep(1, ncol(Y)), n.init = 10,
                zetacutoff = c(-2,20), setMap = setMap)

model4 <- gllvm(y = Y, X = cbind(X, obs = factor(1:nrow(X))), lv.formula = ~obs, num.RR = 2,
                row.eff = ~(1|site/plot), studyDesign = X,
                family = "orderedBeta", disp.formula = rep(1, ncol(Y)),
                zetacutoff = c(-2,20), setMap = setMap)
anova(model2, model4)

model5 <- gllvm(y = Y, num.lv = 2,
                row.eff = ~(1|site/plot), studyDesign = X,
                family = "orderedBeta", disp.formula = rep(1, ncol(Y)),
                zetacutoff = c(-2,20), setMap = setMap)
anova(model3, model5)
anova(model2, model3)

model6 <- gllvm(y = Y, X = X,
                lv.formula = ~(0+dist_int_veg|1) + (0+caco|1) + (0+slope|1) + (0+loi|1) + (0+grain_size_stand_f|1) + (0+years_since_n|1) + (0+gf|1),
                num.RR = 2, randomB = "P",
                family = "orderedBeta", disp.formula = rep(1, ncol(Y)), n.init = 10,
                zetacutoff = c(-2,20), setMap = setMap)
gllvm::ordiplot(model6)
summary(model6)

model7 <- gllvm(y = Y, X = X,
                lv.formula = ~(0+dist_int_veg|1) + (0+caco|1) + (0+slope|1) + (0+loi|1) + (0+grain_size_stand_f|1) + (0+years_since_n|1) + (0+gf|1),
                num.RR = 2, randomB = "LV",
                family = "orderedBeta", disp.formula = rep(1, ncol(Y)), n.init = 10,
                zetacutoff = c(-2,20), setMap = setMap)
gllvm::ordiplot(model7)
corrplot::corrplot(getEnvironCor(model7), type = "lower", order = "AOE", diag = FALSE, tl.pos = "l", tl.cex = 0.2, addgrid.col = NA)
