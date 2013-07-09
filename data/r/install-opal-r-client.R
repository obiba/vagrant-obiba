#! /usr/bin/Rscript --vanilla

# Install opal and opaladmin R packages
install.packages('opaladmin', repos=c('http://cran.rstudio.com', 'http://cran.obiba.org'), dependencies=TRUE)
# Install datashied client R packages
install.packages('datashieldclient', repos=c('http://cran.rstudio.com', 'http://cran.obiba.org'), dependencies=TRUE)

# Install datashield server R packages via opal
library(opaladmin)
o<-opal.login('administrator', 'password', url='http://localhost:8080')
dsadmin.install_package(o, 'datashield')
