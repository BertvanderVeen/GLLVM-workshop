# Auto-generated from Practicals/Rmd/4Practical.Rmd via knitr::purl(). Do not edit directly -- re-run after editing the Rmd. See Practicals/R/README.md.

Y <- read.csv("../../data/alpineY.csv")[,-1]
X <- read.csv("../../data/alpineX.csv")[,-1]
# You could choose to a-priori scale covariates before fitting the model.
# X <- data.frame(lapply(X, function(x)if(is.numeric(x)){scale(x)}else{as.factor(x)}))

dim(Y)
colnames(X)

min(colSums(Y))
table(rowSums(ifelse(Y==0,0,1))>3)

X <- X[rowSums(Y)>0, ]
Y <- Y[rowSums(Y)>0,]

library(gllvm)
TMB::openmp(parallel::detectCores()-1, DLL = "gllvm", autopar = TRUE)
model1  <- gllvm(y = Y, num.lv = 2, family = "binomial", Lambda.struc = "diagonal", sd.errors = FALSE, optim.method = "L-BFGS-B")

library(gllvm)
corrplot::corrplot(getResidualCor(model1), type = "lower", order = "AOE", diag = FALSE, tl.pos = "l", tl.cex = 0.2, addgrid.col = NA)

model2  <- gllvm(y = Y, X = X, formula = ~ scale(SLOPE), num.lv = 2, family = "binomial", Lambda.struc = "diagonal", sd.errors = FALSE, optim.method = "L-BFGS-B")

slope_path <- file.path(tempdir(), "slope.tif")
download.file("https://raw.githubusercontent.com/BertvanderVeen/GLLVM-workshop/main/data/slope.tif",
              destfile = slope_path, mode = "wb")
slope <- terra::rast(slope_path)

slp_scale = scale(X$SLOPE)
Xnew = cbind(1, terra::values(slope)-attr(slp_scale,"scaled:center"))/attr(slp_scale,"scaled:scale")
eta=Xnew%*%t(cbind(model2$params$beta0, model2$params$Xcoef))
preds <- pnorm(eta)
predrast <- terra::rast(slope, nl=ncol(model2$y))
terra::values(predrast) <- preds

library(terra)
par(mfrow = c(1,2))
plot(predrast[[1]], main = colnames(Y)[1])
plot(predrast[[2]], main = colnames(Y)[2])

goodnessOfFit(Y, object = model1, measure = "TjurR2")
