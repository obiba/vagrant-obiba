#! /usr/bin/Rscript --vanilla

# Publish datashield server R packages in opal
library(opaladmin)
o<-opal.login('administrator', 'password', url='http://localhost:8080')
dsadmin.set_package_methods(o, 'dsbase')
dsadmin.set_package_methods(o, 'dsmodelling')
dsadmin.set_package_methods(o, 'dsteststats')
