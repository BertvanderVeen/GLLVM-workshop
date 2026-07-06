## ============================================================================
## Garchinger Heide: joint gllvm analysis across survey methods
##
## Question: do species occupy the same ordination space whether they were
## recorded by the frequency method (1984/1993/2018, Raunkiaer, /100 quadrats)
## or the coverage method (2003/2018, Braun-Blanquet/Londo, % cover)?
##
## Design: stack both surveys' plots as rows (physically disjoint, so no
## repeated rows to exploit).  For each species recorded by both methods,
## create two columns (..._COV, ..._FREQ) so the response type can differ
## per column while num.lv latent variables are estimated jointly across all
## rows.  Species loadings for the same species under both methods then end
## up in one common, rotation-aligned latent space.
## ============================================================================
setwd("/home/bertv/github/GLLVM-workshop/4Friday/")
source("load_garchinger_heide_gllvm.R")
library(gllvm)

## ---------------------------------------------------------------------------
## Model sequence: unconstrained -> spatial -> spatial + temporal + method
## ---------------------------------------------------------------------------
TMB::openmp(12, autopar = TRUE, DLL = "gllvm")

## fit3: unconstrained joint model — shared species only as anchor
fit3 <- gllvm(
  y            = Y_joint,
  family       = family_vec,
  Ntrials      = Ntrials,
  num.lv       = 2,zeta.struc="common",
  sd.errors    = FALSE,
  seed         = 1, jitter.var = 0,n.init=100, n.init.max = 20, row.eff=~(1|site),studyDesign=data.frame(site=physical_site))

plot(fit3, which = 2, spp = which(family_vec == "ordinal"))
plot(fit3, which = 2, spp = which(family_vec == "ZNIB"))

# One of the poor fitting species
hist(na.omit(Y_joint[,which(family_vec=="ZNIB")[6]]))

## fit4: add spatial corExp on LVs — nearby cross-survey plots anchor the spaces
fit4 <- update(fit3,
  distLV      = coords_sites,
  lvCor       = ~corExp(1|site),
  studyDesign = data.frame(site = physical_site),
  Lambda.struct = "UNN")

## fit5: add Year as concurrent covariate + Method as random intercept
## - lv.formula = ~Year rotates LVs toward temporal variation
## - formula = ~(1|Method) absorbs survey-method offset outside the ordination
fit5 <- update(fit4,
               num.lv= 0,
  X          = X_joint,
  num.lv.c   = 2,
  lv.formula = ~ Year,
  randomB    = "LV",
  lvCor       = ~corExp(1|site),
  Lambda.struct = "UNN")

## ---------------------------------------------------------------------------
## 5. Do the same species occupy the same ordination space across methods?
## ---------------------------------------------------------------------------
gamma <- getLoadings(fit3)

align <- data.frame(species = shared$freq, cosine = NA_real_, correlation = NA_real_)
for (i in seq_len(nrow(shared))) {
  g_cov  <- gamma[paste0(shared$freq[i], "_COV"),  ]
  g_freq <- gamma[paste0(shared$freq[i], "_FREQ"), ]
  align$cosine[i]      <- sum(g_cov * g_freq) / (sqrt(sum(g_cov^2)) * sqrt(sum(g_freq^2)))
  align$correlation[i] <- suppressWarnings(cor(g_cov, g_freq))
}
cat("Loading alignment: cosine similarity between coverage and frequency loadings\n")
print(summary(align$cosine))
print(align[order(align$cosine), ])

## Paired-arrow biplot: one arrow per shared species connecting _COV to _FREQ loading
plot(gamma[, 1:2], type = "n", xlab = "LV1", ylab = "LV2",
     main = "Species loadings: coverage vs frequency survey")
for (i in seq_len(nrow(shared))) {
  p_cov  <- gamma[paste0(shared$freq[i], "_COV"),  1:2]
  p_freq <- gamma[paste0(shared$freq[i], "_FREQ"), 1:2]
  segments(p_cov[1], p_cov[2], p_freq[1], p_freq[2], col = "grey70")
}
points(gamma[col_cov,     1:2], pch = 16, col = "forestgreen")
points(gamma[col_fshared, 1:2], pch = 17, col = "steelblue")
legend("topright", c("coverage", "frequency"), pch = c(16, 17),
       col = c("forestgreen", "steelblue"))

## ---------------------------------------------------------------------------
## 6. Procrustes comparison of loadings from the two survey types
## ---------------------------------------------------------------------------
gamma <- getLoadings(fit3)

load_cov  <- gamma[col_cov,     , drop = FALSE]
load_freq <- gamma[col_fshared, , drop = FALSE]
rownames(load_cov) <- rownames(load_freq) <- shared$freq[ord_shared]

pr <- vegan::procrustes(load_cov, load_freq, symmetric = TRUE)
print(summary(pr))
vegan::protest(load_cov, load_freq, permutations = 999)

## ---------------------------------------------------------------------------
## 7. Three ordination biplots, one per species group
##    Species colored by survey method: goldenrod = coverage, steelblue = frequency
## ---------------------------------------------------------------------------
cosine <- align$cosine[ord_shared]   # reorder to match col_cov / col_fshared
group  <- ifelse(cosine >  0.5, "agree",
          ifelse(cosine < -0.5, "opposite", "intermediate"))

site_col <- ifelse(grepl("^COV_", levels(physical_site)), "goldenrod", "steelblue")

make_spp_vecs <- function(show_cov_cols, show_freq_cols) {
  col <- rep("transparent", length(all_cols)); names(col) <- all_cols
  cex <- rep(0,             length(all_cols)); names(cex) <- all_cols
  col[show_cov_cols]  <- "goldenrod"
  col[show_freq_cols] <- "steelblue"
  cex[c(show_cov_cols, show_freq_cols)] <- 0.7
  list(col = col, cex = cex)
}

v_agree    <- make_spp_vecs(col_cov[group == "agree"],
                             c(col_fshared[group == "agree"]))
v_opposite <- make_spp_vecs(col_cov[group == "opposite"],
                             c(col_fshared[group == "opposite"]))
v_rest     <- make_spp_vecs(c(col_cov[group == "intermediate"], col_conly),
                             c(col_fshared[group == "intermediate"], col_fonly))

par(mfrow = c(1, 3))
ordiplot(fit3, biplot = TRUE, s.colors = site_col,
         spp.colors = v_agree$col,    cex.spp = v_agree$cex,
         main = "Agree (COV ≈ FREQ)", xlim = c(-5,5), ylim = c(-3,3), symbols = TRUE, fac.center=TRUE)
ordiplot(fit3, biplot = TRUE, s.colors = site_col,
         spp.colors = v_opposite$col, cex.spp = v_opposite$cex,
         main = "Opposite (COV ≈ -FREQ)", xlim = c(-5,5), ylim = c(-3,3), symbols = TRUE, fac.center=TRUE)
ordiplot(fit3, biplot = TRUE, s.colors = site_col,
         spp.colors = v_rest$col,     cex.spp = v_rest$cex,
         main = "Intermediate / survey-only", xlim = c(-5,5), ylim = c(-3,3), symbols = TRUE, fac.center=TRUE)
par(mfrow = c(1, 1))

## ---------------------------------------------------------------------------
## 8. Spatial distance decay of LV correlations
##
## corExp model: Cor(u_i, u_j) = exp(-d_ij / rho)
## rho.lv1 and rho.lv2 are in km (coords divided by 1000 before fitting)
## ---------------------------------------------------------------------------
rho <- fit3$params$rho.lv   # named rho.lv1, rho.lv2

## effective range: distance at which correlation drops to 0.05 (= -rho*log(0.05))
eff_range <- -rho * log(0.05)   # in km
d_max <- max(eff_range) * 1.5   # zoom to 1.5x the longer effective range
d_seq <- seq(0, d_max, length.out = 500)

plot(d_seq * 1000, exp(-d_seq / rho[1]),
     type = "l", lwd = 2, col = "steelblue",
     xlab = "Distance (m)", ylab = "Spatial correlation",
     main = "Distance decay of LV spatial correlation",
     ylim = c(0, 1))
lines(d_seq * 1000, exp(-d_seq / rho[2]), lwd = 2, col = "goldenrod", lty = 2)
abline(h = 0.05, lty = 3, col = "grey50")
abline(v = eff_range[1] * 1000, lty = 3, col = "steelblue")
abline(v = eff_range[2] * 1000, lty = 3, col = "goldenrod")
legend("topright",
       legend = c(sprintf("LV1  (effective range = %.0f m)", eff_range[1] * 1000),
                  sprintf("LV2  (effective range = %.0f m)", eff_range[2] * 1000),
                  "Cor = 0.05 threshold"),
       lwd = c(2, 2, 1), lty = c(1, 2, 3),
       col = c("steelblue", "goldenrod", "grey50"))

# map
library(ggplot2)

# ── colour scheme ──────────────────────────────────────────────────────────────
col_map <- c(
    "COV 2003"  = "#1D9E75",
    "COV 2018"  = "#085041",
    "FREQ 1984" = "#7F77DD",
    "FREQ 1993" = "#534AB7",
    "FREQ 2018" = "#3C3489"
)

# ── build plot data ────────────────────────────────────────────────────────────
df <- data.frame(
    E      = coords_joint$E,
    N      = coords_joint$N,
    year   = X_joint$Year,
    method = X_joint$Method,
    label  = paste0(X_joint$Method, " ", X_joint$Year),
    row.names = rownames(coords_joint)
)

# block / transect from rownames
df$group <- sub("^X[0-9]{2}([A-Z]+)[0-9]+$", "\\1", rownames(df))

# centroid per group × method for labels
lab_df <- aggregate(cbind(E, N) ~ group + method, data = df, FUN = mean)

# ── plot ───────────────────────────────────────────────────────────────────────
ggplot(df, aes(x = E, y = N, colour = label, shape = method)) +
    geom_point(size = 2.5, alpha = 0.85, stroke = 0.3) +
    geom_text(
        data = lab_df,
        aes(x = E, y = N, label = group),
        colour    = "grey40",
        fontface  = "bold",
        size      = 3.2,
        nudge_x   = 8,
        nudge_y   = 12,
        inherit.aes = FALSE
    ) +
    scale_colour_manual(values = col_map, name = NULL) +
    scale_shape_manual(values = c("COV" = 16, "FREQ" = 17), name = NULL) +
    coord_equal() +
    labs(
        x = "Easting (m)",
        y = "Northing (m)"
    ) +
    theme_minimal(base_size = 11) +
    theme(
        legend.position  = "bottom",
        legend.key.size  = unit(0.5, "lines"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(colour = "grey92", linewidth = 0.3)
    ) +
    guides(
        colour = guide_legend(nrow = 2, override.aes = list(size = 3)),
        shape  = guide_legend(nrow = 1, override.aes = list(size = 3))
    )
