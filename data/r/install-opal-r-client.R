#! /usr/bin/Rscript --vanilla

# Install opal and opaladmin R packages
install.packages('opaladmin', repos=c('http://cran.rstudio.com', 'http://cran.obiba.org'), dependencies=TRUE)
