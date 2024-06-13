library(gllvm)
data(spider, package="mvabund")

model <- gllvm(spider$abund, num.lv = 2, family = "poisson", quadratic = TRUE)
model1 <- gllvm(spider$abund, num.lv = 2, family = "poisson", quadratic = TRUE, n.init = 100, n.init.max = 10, trace = TRUE)
# model1 here has a worse likelihood than model

# change optimizer and optimizer algorithms
model <- update(model, optimizer = "nlminb", maxit = 1e6, max.iter=1e6, reltol=1e-15)
model <- update(model, gradient.check = TRUE)

# Check gradient: should be zero
hist(model$TMBfn$gr())
grd <- c(model$TMBfn$gr())
names(grd) <- names(model$TMBfn$par)
sort(grd)

# simplify model
model <- update(model, quadratic = "LV")

# Check gradient: should be zero
# This is perfect! All zeros
hist(model$TMBfn$gr())

hess <- model1$TMBfn$he()

# Are there eigenvalues of the hessian below zero?
nrow(hess)-sum(eigen(hess)$val>0)
