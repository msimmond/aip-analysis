# RCBD

- button for RCBD (thing asking what is the block variable?)
- make it clear that RCBD is a type of anova
- use the dropdown box for ananlysis to select RCBD and then in select
  independent variables, have a specific box for block

# Split plot

agricolae package for this:
 - split block
 - split plot
 - strip block
look up the methods for these

# Both RCBD and Split plot across locations
(and possibly years, but definitely across locations)

- definitely going to be an emphasis with multiple locations
- possible random effects?
- Should we use lme4 or nlme for the mixed models?
  - Sometime lme4 has false convergence issues, but mostly been fixed in 1.1-7
  - I've never used nlme

# imputation?
- when can missing data be used and when should it imputed
- experimental imputation feature - button that will autmatically do imputation
  for the data if a lot of missings are detected
- Include an "undo" button so all isn't lost once they click "impute"
- have a test for whether imputations should be done (i.e. threshold of
  missings; too much missing and don't allow imputation)

# covariates
- optional option for continuous variable?
- User can already select a covariate in the select IV section, it just isn't
  explicit that they can do this.

# Plots
barcharts, hist, scatterplot, should allow title changes, color changes

# Factors

Check whether all factor levels in an interction are there (i.e. table(f1, f2,
useNA='ifany') must have no empty cells)

- if cells are empty, give a warning
- look into models that will run an incomplete factiorial design
- Type II sums of sqaures for balanced
- Type III SS for unbalanced and incomplete

under ANOVA - make it clear that split/strip plot/block is a type of anova

# Other things
- test for poisson data and inform user if they should use glm transformations?
- for dependent variable, test for normality, offer some standard
  transformations
- include diagnostics in report?
- include a tab for model diagnostics in the app

under model check:
- check for poisson
- check normality?
- check full factorial design
- check missingness (use complete.cases() to find nrows in analysis vs. nrow data)

Help tab should include information on
- selecting a data type for glm

Add an option to use drop1() (or step to do it in the opposite direction) to
automatically choose the best fit model. Tell the user to create a saturated
model (or do it automatically based on the IVs selected, all interactions) and
go from there.
