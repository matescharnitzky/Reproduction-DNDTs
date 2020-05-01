
# start

cat(paste(paste(paste(rep(x = "#", 41), collapse = ""), " Loading Packages ", paste(rep(x = "#", 41), collapse = "")), "\n"))

# Package Requirements
packages <- c("tidyverse", # ggplot2, tibble, tidyr, readr, purrr, dplyr, forcats
              "readxl",
              "writexl",
              "rlang",
              "glue",
              "rpart",
              "rpart.plot",
              "rpart.utils",
              "caret",
              "ranger",
              "xgboost"
              )

# Load/install packages

installed_flag <- as.logical(lapply(packages, function(x) require(x, character.only = T))) # check if packages are installed
lapply(packages[!installed_flag], install.packages) # install, if missing
lapply(packages, function(x) require(x, character.only = T)) # load packages

# End

cat(paste(paste(paste(rep(x = "#", 3), collapse = ""), " Packages are installed and loaded "), "\n"))
    