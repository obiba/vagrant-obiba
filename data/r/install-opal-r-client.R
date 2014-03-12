#! /usr/bin/Rscript --vanilla

# Install opal and opaladmin R packages
install.packages('opaladmin', repos=c('http://cran.rstudio.com', 'http://cran.obiba.org'), dependencies=TRUE)

# Install datashield client R packages
install.packages('datashieldclient', repos=c('http://cran.rstudio.com', 'http://cran.obiba.org'), dependencies=TRUE)

# Install datashield server R packages via opal
library(opaladmin)
o<-opal.login('administrator', 'password', url='https://localhost:8443')
dsadmin.install_package(o, 'datashield')

# R server needs to be restarted
#dsadmin.set_package_methods(o,pkg='dsbase', type='aggregate')
#dsadmin.set_package_methods(o,pkg='dsbase', type='assign')
#dsadmin.set_package_methods(o,pkg='dsmodelling', type='assign')
#dsadmin.set_package_methods(o,pkg='dsmodelling', type='aggregate')

