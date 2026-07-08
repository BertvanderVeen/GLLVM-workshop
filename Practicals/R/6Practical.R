# Auto-generated from Practicals/Rmd/6Practical.Rmd via knitr::purl(). Do not edit directly -- re-run after editing the Rmd. See Practicals/R/README.md.

Y <- read.csv("../../data/roadY.csv")[,-1]
Y <- Y/100 # Beta responses should be in the range 0,1
X <- read.csv("../../data/roadX.csv")[,-1]
X$site <- as.factor(X$site)
X <- data.frame(lapply(X, function(x)if(is.numeric(x)){scale(x)}else{as.factor(x)}))

Y2 <- Y[,colSums(ifelse(Y==0,0,1))>3]
ncol(Y2)

library(gllvm)
TMB::openmp(parallel::detectCores()-1, autopar = TRUE, DLL = "gllvm")
model1  <- gllvm(y = Y, num.lv = 2, family = "orderedBeta", disp.formula = rep(1,ncol(Y)), starting.val = "zero")
model2  <- gllvm(y = Y2, num.lv = 2, family = "orderedBeta", disp.formula = rep(1,ncol(Y2)), starting.val = "zero")

library(gllvm)
par(mfrow = c(2, 2))
ordiplot(model1, symbols = TRUE, biplot = TRUE)
ordiplot(model2, symbols = TRUE, biplot = TRUE)
ordiplot(model1, symbols = TRUE)
ordiplot(model2, symbols = TRUE)

vegan::procrustes(getLV(model1), getLV(model2), symmetric = TRUE)

NMDS <- vegan::metaMDS(Y, trace = 0)
CA <- vegan::cca(Y)
DCA <- vegan::decorana(Y)
vegan::procrustes(getLV(model1), vegan::scores(NMDS, choices = 1:2), symmetric = TRUE)
vegan::procrustes(getLV(model1), vegan::scores(CA, choices = 1:2), symmetric = TRUE)
vegan::procrustes(getLV(model1), vegan::scores(DCA, choices = 1:2), symmetric = TRUE)

model3  <- gllvm(y = Y2, num.lv = 2,
                 family = "orderedBeta", disp.formula = rep(1,ncol(Y2)),
                 starting.val = "res", row.eff = ~(1|site), studyDesign = X,
                 sd.errors = FALSE, seed = 2)

model4  <- gllvm(y = Y2, X = X, num.lv = 2,
                 family = "orderedBeta", disp.formula = rep(1,ncol(Y2)),
                 starting.val = "res", formula = ~diag(1|site), randomX.start = "zero",
                 Ab.struct = "diagonal", sd.errors = FALSE, seed = 2)

vegan::procrustes(getLV(model3), getLV(model4), symmetric = TRUE)
vegan::procrustes(getLV(model1), getLV(model4), symmetric = TRUE)

vegan::procrustes(getLoadings(model3), getLoadings(model4), symmetric = TRUE)
vegan::procrustes(getLoadings(model2), getLoadings(model4), symmetric = TRUE)

AIC(model3, model4)

model5  <- gllvm(y = Y2, num.lv = 2, family = "orderedBeta", n.init = 10, lvCor = ~(1|site), studyDesign = X[,"site",drop=FALSE], disp.formula = rep(1, ncol(Y2)))
gllvm::ordiplot(model5)

resi <- residuals(model5)$resi
fitted <- predict(model5)
xxx <- boxplot(c(fitted), outline = FALSE, plot = FALSE)$stats
plot(c(resi) ~ c(fitted), xlim = c(min(xxx), max(xxx)), col = rep(X$site, times = ncol(model5$y)), xlab = "Linear predictor", ylab = "Dunn-Smyth residuals")

X$plot<- factor(ave(seq_along(X$site), X$site, FUN = seq_along))

model6  <- gllvm(y = Y2, num.lv = 2, family = "orderedBeta", n.init = 10, lvCor = ~(1|site), studyDesign = X[,c("plot","site"),drop=FALSE], disp.formula = rep(1, ncol(Y2)), row.eff = ~(1|site/plot))

# this draws way too much memory
# model7  <- gllvm(y = Y2, X = X[,c("site","plot")], num.lv = 2, family = "orderedBeta", lvCor = ~(1|site), studyDesign = X[,c("site"),drop=FALSE], disp.formula = rep(1, ncol(Y2)), formula = ~diag(1|site/plot), randomX.start = "res", Ab.struct = "diagonal", sd.errors = FALSE)

resi <- residuals(model6)$resi
fitted <- predict(model6)
xxx <- boxplot(c(fitted), outline = FALSE, plot = FALSE)$stats
plot(c(resi) ~ c(fitted), xlim = c(min(xxx), max(xxx)), col = rep(X$site, times = ncol(model6$y)), xlab = "Linear predictor", ylab = "Dunn-Smyth residuals")
