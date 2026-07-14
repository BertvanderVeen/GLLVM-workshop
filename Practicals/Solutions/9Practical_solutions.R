# Practical 9 solutions: Unimodal response models in gllvm
# Builds on model1 (quadratic = TRUE) as fitted in the practical.

library(gllvm)
TMB::openmp(parallel::detectCores() - 1, autopar = TRUE, DLL = "gllvm")

Y <- read.table("../../data/waddenY.csv", sep = ",", header = TRUE, row.names = 2)[, -1]

# 1. Species-specific tolerances (already model1 in the practical).
model1 <- gllvm(Y, num.lv = 2, quadratic = TRUE, n.init = 3, family = "negative.binomial",
                 disp.formula = rep(1, ncol(Y)), sd.errors = FALSE)
gllvm::ordiplot(model1, biplot = TRUE)
optima(model1, sd.errors = FALSE)
tolerances(model1, sd.errors = FALSE)

# 2. Species-common tolerances, no quadratic term, and a row.eff version.
model_common_tol <- gllvm(Y, num.lv = 2, quadratic = "LV", n.init = 3,
                           family = "negative.binomial", disp.formula = rep(1, ncol(Y)),
                           sd.errors = FALSE)
model_linear <- gllvm(Y, num.lv = 2, quadratic = FALSE, n.init = 3,
                       family = "negative.binomial", disp.formula = rep(1, ncol(Y)),
                       sd.errors = FALSE)
model_roweff <- gllvm(Y, num.lv = 2, quadratic = FALSE, row.eff = "random", n.init = 3,
                       family = "negative.binomial", disp.formula = rep(1, ncol(Y)),
                       sd.errors = FALSE)
# quadratic = FALSE with row.eff = "random" at the observation level gives
# equal (common) tolerances "for free", without estimating them explicitly.

# 3. Compare the ordinations.
vegan::procrustes(getLV(model1), getLV(model_common_tol), symmetric = TRUE)
vegan::procrustes(getLV(model1), getLV(model_linear), symmetric = TRUE)
cor(getLV(model1)[, 1], getLV(model_linear)[, 1])
# A large Procrustes error (or low correlation) between the quadratic and
# linear ordinations is exactly the "we miss the dominant gradient with a
# misspecified model" warning from the lecture. On this data, model_common_tol
# and model_linear turn out nearly identical, while model1 (species-specific
# tolerances) diverges from both, so check the actual numbers rather than
# assuming species-specific and species-common tolerances agree more closely
# with each other than either does with the linear model.

# 4. Model selection.
AIC(model1, model_common_tol, model_linear, model_roweff)
BIC(model1, model_common_tol, model_linear, model_roweff)
# model_roweff adds a row.eff variance (boundary comparison, Practical 2's
# Hypothesis Testing section); read that part of the table cautiously. Only
# trust model1's AIC/BIC preference if it clearly outweighs its extra
# parameters (and recall the n.init warning: refit a few times first, since
# the quadratic model is prone to local optima).

# 5. Add covariates to the quadratic ordination.
X <- read.table("../../data/waddenX.csv", sep = ",", header = TRUE, row.names = 2)[, -1]
X <- X[, -which(apply(X, 2, anyNA))]
model_constrained <- gllvm(Y, X = X, lv.formula = ~scale(silt_clay) + scale(elevation),
                            num.RR = 2, quadratic = TRUE, family = "negative.binomial",
                            disp.formula = rep(1, ncol(Y)), n.init = 3, sd.errors = FALSE)
model_concurrent <- gllvm(Y, X = X, lv.formula = ~scale(silt_clay) + scale(elevation),
                           num.lv.c = 2, quadratic = TRUE, family = "negative.binomial",
                           disp.formula = rep(1, ncol(Y)), n.init = 3, sd.errors = FALSE)
model_randomB <- gllvm(Y, X = X, lv.formula = ~(0+scale(silt_clay)|1) + (0+scale(elevation)|1),
                        num.RR = 2, randomB = "LV", quadratic = TRUE, family = "negative.binomial",
                        disp.formula = rep(1, ncol(Y)), n.init = 3, sd.errors = FALSE)
# All three keep species' unimodal (optimum + tolerance) responses along the
# ordination axes, but now those axes are informed (num.lv.c) or fully
# constrained (num.RR, fixed or random via randomB) by silt_clay/elevation,
# turning "where is this species' optimum on the gradient" into "where is
# this species' optimum along the silt_clay/elevation gradient", directly
# comparable to the constrained-ordination practical from Thursday.
