# Practicals/R

Code-only companions to the practicals in `Practicals/Rmd/`, one `.R` file per practical. These are extracted automatically from the `.Rmd` sources with `knitr::purl()`: prose is stripped, only code chunks (and any comments already written inside them) remain.

## Keeping these in sync

These files are derived, not authored directly. Whenever a `Practicals/Rmd/*Practical.Rmd` file changes, its corresponding `Practicals/R/*Practical.R` file goes stale and must be regenerated. Do not hand-edit the `.R` files here; edit the `.Rmd` and regenerate instead.

To regenerate all ten:

```r
setwd("Practicals/Rmd")
for (i in 1:10) {
  rmd <- sprintf("%dPractical.Rmd", i)
  out <- sprintf("../R/%dPractical.R", i)
  knitr::purl(rmd, output = out, documentation = 0, quiet = TRUE)
  header <- sprintf("# Auto-generated from Practicals/Rmd/%dPractical.Rmd via knitr::purl(). Do not edit directly -- re-run after editing the Rmd. See Practicals/R/README.md.", i)
  code <- readLines(out)
  writeLines(c(header, "", code), out)
}
```

To regenerate a single file after editing one Rmd, run just that iteration (or the two-line `knitr::purl()` + header call) for the relevant practical number.
