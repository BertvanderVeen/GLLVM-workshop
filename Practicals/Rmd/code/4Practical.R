# Dataset by Podani and Miklos (2002)
tmp <- tempfile()
download.file("https://github.com/gavinsimpson/random_code/raw/master/podani.R", tmp)
source(tmp)
PM1 <- podani1()

# Dataset by Minchin (1987), see ter Braak and Smilauer (2015)
MC <- read.csv("https://raw.githubusercontent.com/BertvanderVeen/Examples/master/Minchin87_2b_counts.csv",skip=1)
MC[is.na(MC)] <- 0

library(gllvm)
library(vegan)
model1 <- gllvm(PM1, num.lv = 2, family = "poisson", starting.val = "res", sd.errors = FALSE)
model2 <- gllvm(PM1, num.lv = 2, family = "poisson", starting.val = "zero", sd.errors = FALSE)
model3 <- gllvm(PM1, num.lv = 2, family = "poisson", starting.val = "random", sd.errors = FALSE)

logLik(model1)
logLik(model2)
logLik(model3)

procrustes(getLV(model1), getLV(model2), symmetric = TRUE)

par(mfrow = c(1, 2))
gllvm::ordiplot(model1)
gllvm::ordiplot(model2)

procrustes(getLV(model1), getLV(model3), symmetric = TRUE)
procrustes(getLV(model2), getLV(model3), symmetric = TRUE)

par(mfrow=c(1,1))
gllvm::ordiplot(model3)

# Check magnitude of gradient: these should be zero for a converged model
hist(model3$TMBfn$gr())

DCA <- vegan::decorana(PM1)
procrustes(scores(DCA, choices=1:2), getLV(model1), symmetric = TRUE)
plot(DCA)

NMDS <- metaMDS(PM1)
procrustes(scores(NMDS, choices=1:2)$sites, getLV(model1), symmetric = TRUE)

# Minchin
model4 <- gllvm(MC, num.lv = 2, family = "poisson", sd.errors = FALSE)

# checking residuals
plot(model4)

# Look at ordination plot
gllvm::ordiplot(model4)

# improve the model with a random site effect
model5 <- gllvm(MC, num.lv = 2, family = "poisson", row.eff = "random", sd.errors = FALSE)
gllvm::ordiplot(model5)

# change to NB
model6 <- gllvm(MC, num.lv = 2, family = "negative.binomial", row.eff = "random", sd.errors = FALSE, n.init = 3, jitter.var=0.1)
# change to NB
model6b <- gllvm(MC, num.lv = 2, family = "negative.binomial", row.eff = "fixed", sd.errors = FALSE)

NMDS2 <- metaMDS(MC)
procrustes(NMDS2, getLV(model6), symmetric=TRUE)

# Try LA and EVA
model7 <- gllvm(MC, num.lv = 2, family = "negative.binomial", row.eff = "random", method="EVA", sd.errors = FALSE)
model8 <- gllvm(MC, num.lv = 2, family = "negative.binomial", row.eff = "random", method="LA", sd.errors = FALSE)

procrustes(getLV(model7), NMDS2, symmetric=TRUE)
procrustes(getLV(model8), NMDS2, symmetric=TRUE)

# fit an unimodal response model
# takes quite a bit longer
model6quad <- update(model6, quadratic=TRUE, row.eff=FALSE, family="poisson", n.init = 3)
ordiplot(model6quad,rotate=FALSE) # a near perfect lattice