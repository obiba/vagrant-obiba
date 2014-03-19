#! /usr/bin/Rscript --vanilla

# Install datashield server R packages via opal
library(opaladmin)
o<-opal.login('administrator', 'password', url='https://localhost:8443')
dsadmin.install_package(o, 'datashield')
opal.logout(o)