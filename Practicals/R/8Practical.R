# Auto-generated from Practicals/Rmd/8Practical.Rmd via knitr::purl(). Do not edit directly -- re-run after editing the Rmd. See Practicals/R/README.md.

library(gllvm)
TMB::openmp(parallel::detectCores()-1, autopar = TRUE, DLL = "gllvm")

Y <- read.csv("../../data/waddenY2.csv")[, -c(1:2)]
Y <- Y[, colSums(ifelse(Y == 0, 0, 1)) > 2]
X <- read.csv("../../data/waddenX.csv")
X <- X[, !apply(X, 2, anyNA)]
X[, unlist(lapply(X, is.numeric))] <- scale(X[, unlist(lapply(X, is.numeric))])

model1 <- gllvm(Y, num.lv = 2, family = "tweedie", Power = NULL,
                disp.formula = rep(1, ncol(Y)), n.init = 3)
gllvm::ordiplot(model1, symbols = TRUE, s.cex = 1.5)

model2 <- gllvm(Y, num.lv = 2, family = "tweedie", Power = NULL,
                disp.formula = rep(1, ncol(Y)),
                row.eff = ~(1|island), studyDesign = X, n.init = 3)
gllvm::ordiplot(model2, symbols = TRUE, s.cex = 1.5)

vegan::procrustes(getLV(model1), getLV(model2), symmetric = TRUE)

model3 <- gllvm(Y, X = X,
                lv.formula = ~season + TOC + elevation + silt_clay + Chl.a,
                num.RR = 2, randomB = "LV",
                family = "tweedie", Power = NULL,
                disp.formula = rep(1, ncol(Y)),
                row.eff = ~(1|island), studyDesign = X,
                n.init = 3)
gllvm::ordiplot(model3, symbols = TRUE, s.cex = 1.5, arrow.ci = FALSE)

VP(model3)
