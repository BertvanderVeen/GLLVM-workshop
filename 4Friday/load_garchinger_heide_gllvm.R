## ============================================================================
## Garchinger Heide calcareous-grassland monitoring -> gllvm-ready data
##
## Source (CC-BY 4.0): Bauer, M.; Albrecht, H. (2022). Vegetation surveys from
## the calcareous grassland of the nature reserve Garchinger Heide [dataset
## bundled publication]. PANGAEA. https://doi.org/10.1594/PANGAEA.940643
## Underlying paper: Bauer & Albrecht (2020), Basic and Applied Ecology 42,
## 15-26. https://doi.org/10.1016/j.baae.2019.11.003
##
## Produces two gllvm-ready datasets:
##   coverage  : 84 rows (42 plots x {2003, 2018})
##              Londo ordinal codes (0, 0.1, 0.2, 0.4, 1..8) -> ordinal
##   frequency : 120 rows (40 plots x {1984, 1993, 2018})
##              Raunkiaer frequency (/100 quadrats) -> binomial, Ntrials = 100
## Each is a list(Y = site-by-species matrix, X = covariate data.frame).
## ============================================================================

read_pangaea <- function(url) {
  raw <- readLines(url, encoding = "UTF-8", warn = FALSE)
  end_comment <- which(raw == "*/")
  stopifnot(length(end_comment) == 1)
  txt <- paste(raw[(end_comment + 1):length(raw)], collapse = "\n")
  read.delim(text = txt, sep = "\t", check.names = FALSE, stringsAsFactors = FALSE)
}

## ---------------------------------------------------------------------------
## 1. Coverage dataset (site x species; PANGAEA.940633)
## ---------------------------------------------------------------------------
cov_raw <- read_pangaea("https://doi.pangaea.de/10.1594/PANGAEA.940633?format=textfile")
cov_raw$Event <- NULL
colnames(cov_raw)[1] <- "Plot"   # PANGAEA embeds a truncated parameter comment here

## PANGAEA source has one genuine name collision: "T. montanum cov [%]" for both
## Teucrium montanum and Trifolium montanum; order confirmed against the
## alphabetical species list in Appendix A of the paper.
tm_idx <- which(colnames(cov_raw) == "T. montanum cov [%]")
stopifnot(length(tm_idx) == 2)
colnames(cov_raw)[tm_idx] <- c("Teucrium montanum cov [%]", "Trifolium montanum cov [%]")

species_cols <- setdiff(colnames(cov_raw), "Plot")
clean_name <- function(x) {
  x <- sub("\\s*cov \\[%\\].*$", "", x)
  x <- gsub("\\.\\s*", "_", x)
  x <- gsub("\\s+", "_", x)
  gsub("[^A-Za-z_]", "", x)
}
new_names <- vapply(species_cols, clean_name, character(1))
new_names[grepl("ssp\\. corniculatus", species_cols)] <- "L_corniculatus_corniculatus"
new_names[grepl("ssp\\. hirsutus",     species_cols)] <- "L_corniculatus_hirsutus"
colnames(cov_raw)[colnames(cov_raw) %in% species_cols] <- new_names

m     <- regexec("^X([0-9]{2})([MNS])([0-9]+)$", cov_raw$Plot)
parts <- regmatches(cov_raw$Plot, m)
year2 <- vapply(parts, `[`, character(1), 2)
block <- vapply(parts, `[`, character(1), 3)
pnum  <- vapply(parts, `[`, character(1), 4)

cov_raw$Year   <- factor(c("03" = 2003, "18" = 2018)[year2])
cov_raw$Block  <- factor(block, levels = c("N", "M", "S"))
cov_raw$PlotID <- factor(paste0(cov_raw$Block, pnum))

sp_final   <- setdiff(colnames(cov_raw), c("Plot", "Year", "Block", "PlotID"))
Y_coverage <- as.matrix(cov_raw[, sp_final]); storage.mode(Y_coverage) <- "numeric"
rownames(Y_coverage) <- cov_raw$Plot
Y_coverage <- Y_coverage[, colSums(Y_coverage) > 0]

## ---------------------------------------------------------------------------
## Coverage: raw PANGAEA values are Londo ordinal codes × 10.
## Three non-standard intermediate recordings are rounded to the nearest
## standard class: 3 -> 0.4, 5 -> 0.4, 15 -> 2.
## ---------------------------------------------------------------------------
Y_coverage[Y_coverage == 3]  <- 4
Y_coverage[Y_coverage == 5]  <- 4
Y_coverage[Y_coverage == 15] <- 20
Y_coverage <- Y_coverage / 10

londo_levels <- c(0, 0.1, 0.2, 0.4, 1, 2, 3, 4, 5, 6, 7, 8)
stopifnot(all(Y_coverage %in% londo_levels))

## Integer codes 1..12 for gllvm ordinal family
Y_coverage_ord <- matrix(
  match(Y_coverage, londo_levels),
  nrow = nrow(Y_coverage), ncol = ncol(Y_coverage),
  dimnames = dimnames(Y_coverage)
)
storage.mode(Y_coverage_ord) <- "integer"

X_coverage <- data.frame(Year = cov_raw$Year, Block = cov_raw$Block, PlotID = cov_raw$PlotID,
                          row.names = cov_raw$Plot)

## ---------------------------------------------------------------------------
## 2. Frequency dataset (species x plot in source; PANGAEA.941012) -> transpose
## ---------------------------------------------------------------------------
freq_raw     <- read_pangaea("https://doi.pangaea.de/10.1594/PANGAEA.941012?format=textfile")
species_names <- gsub("\\s+", "_", freq_raw$Species)
plot_ids      <- sub(".*Plot:\\s*(\\S+).*", "\\1", colnames(freq_raw)[-1])

mat <- t(as.matrix(freq_raw[, -1, drop = FALSE]))
mat <- apply(mat, 2, as.numeric)
rownames(mat) <- plot_ids
colnames(mat) <- species_names

m        <- regexec("^X([0-9]{2})(I{1,3})([0-9]+)$", plot_ids)
parts    <- regmatches(plot_ids, m)
year2    <- vapply(parts, `[`, character(1), 2)
transect <- vapply(parts, `[`, character(1), 3)
pnum     <- vapply(parts, `[`, character(1), 4)

Y_frequency <- mat[, colSums(mat) > 0]

X_frequency <- data.frame(
  Year     = factor(c("84" = 1984, "93" = 1993, "18" = 2018)[year2]),
  Transect = factor(transect, levels = c("I", "II", "III")),
  PlotID   = factor(paste0(transect, pnum)),
  row.names = plot_ids
)

## ---------------------------------------------------------------------------
## 3. Sanity checks
## ---------------------------------------------------------------------------
stopifnot(nrow(Y_coverage)  == 84,  nrow(X_coverage)  == 84)
stopifnot(nrow(Y_frequency) == 120, nrow(X_frequency) == 120)

## ---------------------------------------------------------------------------
## 4. Plot coordinates (GK4, metres) -- from Bauer & Albrecht (2020) Table A1
##    PlotID matches X_coverage$PlotID and X_frequency$PlotID
## ---------------------------------------------------------------------------
coords_coverage <- data.frame(
  PlotID = c(sprintf("N%02d", 1:6),
             sprintf("M%02d", 1:18),
             sprintf("S%02d", 1:18)),
  E = c(4474411,4474372,4474362,4474370,4474380,4474382,
        4474360,4474380,4474366,4474362,4474374,4474355,4474318,4474304,4474306,
        4474309,4474313,4474310,4474347,4474362,4474357,4474348,4474355,4474346,
        4474258,4474266,4474269,4474277,4474286,4474283,4474329,4474334,4474343,4474339,
        4474342,4474340,4474445,4474450,4474457,4474458,4474461,4474461),
  N = c(5350844,5350905,5350889,5350882,5350871,5350862,
        5350424,5350442,5350435,5350430,5350425,5350433,5350471,5350461,5350465,
        5350477,5350482,5350488,5350451,5350472,5350463,5350457,5350457,5350461,
        5350151,5350145,5350113,5350121,5350129,5350132,5350078,5350076,5350073,5350069,
        5350065,5350065,5350000,5350000,5350000,5349996,5350002,5350008),
  stringsAsFactors = FALSE
)

coords_frequency <- data.frame(
  PlotID = c("I1","I2","I3","I4","I5","I6","I7","I8","I9","I10",
             "I11","I12","I13","I14","I15","I16","I17","I18","I19","I20",
             "I21","I22","I23","I24","I25","I26","I27",
             "II1","II2","II3","II4","II5","II6","II7","II8","II14",
             "III1","III2","III3","III16"),
  E = c(4474342,4474347,4474352,4474356,4474361,4474365,4474370,4474374,4474378,4474383,
        4474387,4474392,4474396,4474401,4474405,4474410,4474414,4474418,4474423,4474427,
        4474431,4474436,4474441,4474444,4474449,4474454,4474457,
        4474253,4474258,4474262,4474267,4474271,4474275,4474280,4474284,4474310,
        4474164,4474168,4474172,4474230),
  N = c(5350027,5350036,5350044,5350054,5350063,5350071,5350079,5350089,5350097,5350106,
        5350115,5350125,5350133,5350142,5350151,5350160,5350169,5350178,5350187,5350196,
        5350205,5350213,5350223,5350231,5350240,5350249,5350261,
        5350071,5350080,5350089,5350098,5350107,5350116,5350125,5350134,5350189,
        5350115,5350124,5350133,5350250),
  stringsAsFactors = FALSE
)

stopifnot(nrow(coords_coverage) == 42, nrow(coords_frequency) == 40)

garchinger <- list(
  coverage  = list(Y = Y_coverage, Y_ord = Y_coverage_ord, X = X_coverage),
  frequency = list(Y = Y_frequency, X = X_frequency),
  coords    = list(coverage = coords_coverage, frequency = coords_frequency)
)

str(garchinger, max.level = 2, list.len = 5)

## ---------------------------------------------------------------------------
## 5. Joint design: match species across surveys, stack matrices, build
##    covariates ready for gllvm()
## ---------------------------------------------------------------------------
match_species <- function(cov_name, freq_names) {
  ct     <- strsplit(cov_name, "_")[[1]]
  genus  <- ct[1]; epithet <- tolower(ct[2])
  ssp    <- if (length(ct) > 2) tolower(ct[3]) else NA_character_

  ft       <- strsplit(freq_names, "_")
  fgenus   <- vapply(ft, `[`, character(1), 1)
  fepithet <- tolower(vapply(ft, `[`, character(1), 2))
  fssp     <- vapply(ft, function(x) if (length(x) > 2) tolower(x[length(x)]) else NA_character_,
                     character(1))

  genus_ok <- if (nchar(genus) == 1) {
    toupper(substr(fgenus, 1, 1)) == toupper(genus)
  } else {
    tolower(fgenus) == tolower(genus)
  }
  hit <- genus_ok & fepithet == epithet & (is.na(ssp) | fssp == ssp)
  freq_names[hit]
}

cov_names  <- colnames(garchinger$coverage$Y)
freq_names <- colnames(garchinger$frequency$Y)

pairs <- lapply(cov_names, match_species, freq_names = freq_names)
lens  <- lengths(pairs)

if (any(lens > 1))
  message("Ambiguous matches excluded from shared set: ",
          paste(cov_names[lens > 1], collapse = ", "))

shared   <- data.frame(cov  = cov_names[lens == 1],
                       freq = unlist(pairs[lens == 1]),
                       stringsAsFactors = FALSE)
cov_only <- cov_names[lens != 1]
freq_only <- setdiff(freq_names, shared$freq)

cat(sprintf("Shared species (paired columns): %d\nFrequency-only: %d\nCoverage-only: %d\n\n",
            nrow(shared), length(freq_only), length(cov_only)))

## Order species by descending non-zero count within each block.
## Shared species use combined count so COV and FREQ columns stay paired.
nz_shared <- colSums(garchinger$frequency$Y[, shared$freq, drop = FALSE] > 0) +
             colSums(garchinger$coverage$Y_ord[, shared$cov, drop = FALSE] > 1)
nz_fonly  <- colSums(garchinger$frequency$Y[, freq_only, drop = FALSE] > 0)
nz_conly  <- colSums(garchinger$coverage$Y_ord[, cov_only, drop = FALSE] > 1)

ord_shared <- order(-nz_shared)
ord_fo     <- order(-nz_fonly)
ord_co     <- order(-nz_conly)

col_fshared <- paste0(shared$freq[ord_shared], "_FREQ")
col_fonly   <- paste0(freq_only[ord_fo],       "_FREQ")
col_cov     <- paste0(shared$freq[ord_shared], "_COV")
col_conly   <- paste0(cov_only[ord_co],        "_COV")
all_cols    <- c(col_fshared, col_fonly, col_cov, col_conly)

rn_cov  <- rownames(garchinger$coverage$Y)
rn_freq <- rownames(garchinger$frequency$Y)
stopifnot(length(intersect(rn_cov, rn_freq)) == 0)

Y_joint <- matrix(NA_real_,
                  nrow = length(rn_cov) + length(rn_freq),
                  ncol = length(all_cols),
                  dimnames = list(c(rn_cov, rn_freq), all_cols))
Y_joint[rn_freq, col_fshared] <- garchinger$frequency$Y[, shared$freq[ord_shared]]
Y_joint[rn_freq, col_fonly]   <- garchinger$frequency$Y[, freq_only[ord_fo]]
Y_joint[rn_cov,  col_cov]     <- garchinger$coverage$Y_ord[, shared$cov[ord_shared]]
Y_joint[rn_cov,  col_conly]   <- garchinger$coverage$Y_ord[, cov_only[ord_co], drop = FALSE]

family_vec <- ifelse(grepl("_COV$", all_cols), "ordinal", "ZNIB")
Ntrials    <- ifelse(grepl("_COV$", all_cols), 1, 100)

## Spatial coordinates for all stacked rows (GK4, metres)
coords_cov  <- garchinger$coords$coverage[
  match(as.character(garchinger$coverage$X$PlotID), garchinger$coords$coverage$PlotID),
  c("E", "N")]
coords_freq <- garchinger$coords$frequency[
  match(as.character(garchinger$frequency$X$PlotID), garchinger$coords$frequency$PlotID),
  c("E", "N")]
coords_joint <- rbind(coords_cov, coords_freq)
rownames(coords_joint) <- rownames(Y_joint)
stopifnot(nrow(coords_joint) == nrow(Y_joint), !anyNA(coords_joint))

## One physical-plot factor and one coordinate row per unique plot (in km)
physical_site <- factor(c(
  paste0("COV_",  as.character(garchinger$coverage$X$PlotID)),
  paste0("FREQ_", as.character(garchinger$frequency$X$PlotID))
))
coords_sites <- as.matrix(coords_joint)[
  match(levels(physical_site), as.character(physical_site)), ] / 1000

X_joint <- data.frame(
  Year   = factor(c(as.character(garchinger$coverage$X$Year),
                    as.character(garchinger$frequency$X$Year))),
  Method = factor(c(rep("COV",  nrow(garchinger$coverage$Y)),
                    rep("FREQ", nrow(garchinger$frequency$Y)))),
  row.names = rownames(Y_joint)
)
