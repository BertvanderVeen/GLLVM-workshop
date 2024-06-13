data(spider, package = "mvabund")
Y <- spider$abund;row.names(Y) <- 1:nrow(Y)
X <- scale(spider$x)

# boral package
library(boral)
t1 <- system.time(model1 <- boral(Y, X, formula.X = ~ soil.dry + moss + fallen.leaves, lv.control = list(num.lv = 2), family = "poisson", save.model = TRUE))
library(gllvm)
t2 <- system.time(model2 <- gllvm(Y, X, formula = ~ soil.dry + moss + fallen.leaves, num.lv = 2, family = "poisson", sd.errors = FALSE))
sdErr <- se(model2)
model2$sd <- sdErr$sd
model2$Hess <- sdErr$Hess
coefplot(model2, which.Xcoef = "soil.dry")

model1$geweke.diag
mcmcs <- get.mcmcsamples(model1)
coda::traceplot(mcmcs)
coefsplot("soil.dry", model1)
coefsplot("soil.dry", model1)
lvsplot(model1)
calc.varpart(model1)
corrplot::corrplot(get.enviro.cor(model1)$cor, type = "lower", order="AOE")

# HMSC
library(Hmsc)
studyDesign = data.frame(sample=as.factor(1:nrow(Y)))
rL <- Hmsc::HmscRandomLevel(units = studyDesign$sample)
model2 <- Hmsc::Hmsc(Y, XFormula = ~fallen.leaves+soil.dry, XData= data.frame(X),
                     distr = "lognormal poisson", studyDesign = studyDesign, 
                     ranLevels = list(sample = rL))
# Run mcmc
run =  Hmsc::sampleMcmc(model2, samples = 1000, nChains = 3, 
                        transient = 2500)
# make biplot
etaPost=Hmsc::getPostEstimate(run, "Eta")
lambdaPost=Hmsc::getPostEstimate(run, "Lambda")
Hmsc::biPlot(run, etaPost = etaPost, lambdaPost = lambdaPost, factors = c(1,2))
betaPost=Hmsc::getPostEstimate(run, "Beta")
plotBeta(model2, post = betaPost) # heatmap of covariate coefficients

# ecoCopula
library(ecoCopula)
preModel <- stackedsdm(Y, formula_X =~fallen.leaves+moss+soil.dry, data = X)
model3 <- cord(preModel)
plot(model3, biplot=TRUE)
model4 <- cgr(preModel)
plot(model4)

# VGAM
library(VGAM)
# unconstrained (fixed effects) ordination
model5 <- rcim(Y, Rank = 2, family = poissonff)
lvplot(model5) # this plotting function is an acquired taste

# constrained ordination
model6 <- rrvglm(Y ~ soil.dry+fallen.leaves+moss, data=data.frame(X), Rank = 2, family = poissonff)
lvplot(model6)

# Vector GLM
model7 <- vglm(Y ~ soil.dry+fallen.leaves+moss, data=data.frame(X), family = poissonff)
summary(model7)
anova(model7)

# gmf
library(gmf)
# devtools::install_github("kidzik/gmf")
model8 <- gmf::gmf(Y, family = poisson(), p = 2)
plot(rbind(model8$u,model8$v), type = "n", xlab="LV1", ylab="LV2")
text(model8$u)
text(model8$v, col="red")

# RCM
library(RCM)
library(phyloseq)
model9 <- RCM::RCM(Y, k = 2)
plot(model9)

model10 <- RCM(phyloseq(otu_table(spider$abund, taxa_are_rows = FALSE), sample_data(spider$x)), 
              covariates = c("soil.dry", "moss", "fallen.leaves"), k = 2, responseFun = "linear")
plot(model10)