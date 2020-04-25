

# 1. path -----------------------------------------

train_file <- "./data/raw/train.csv"
test_file <- "./data/raw/test.csv"
mapping_file <- "./data/raw/data_description.txt"

# 2. variables ------------------------------------

target_var <- "saleprice"

# 3. model configuration -------------------------

# seed
seed <- 13

# general
train_control <- trainControl(method = "cv", 
                              "number" = 5, 
                              allowParallel = T)

# linear model

lm_grid <- expand.grid(alpha = 1,  # 0 = ridge, 1 = lasso
                       lambda = seq(0.001, 1, by = 0.0005))
                       # subset = T,        # an optional vector specifying a subset of observations to be used in the fitting process
                       # weight = NULL,     # an optional vector of weights to be used in the fitting process
                       # na_action = NULL,  # a function which indicates what should happen when the data contain NAs
                       # method = "qr",     # the method to be used; for fitting, currently only method = "qr" is supported;
                       # model = T,         # returns the model frame
                       # x = F,             # returns the model matrix
                       # y = F,             # returns the response
                       # qr = T,            # returns the QR decomposition
                       # singular_ok = T,   # if False, a singular fit is an error
                       # contrasts = T,     # returns the model frame
                       # offset = NULL      # this can be used to specify an a priori known component to be included in the linear predictor during fitting

# rpart

rpart_grid <- expand.grid(cp = 0)

rpart_control <- list(subset = T,           # optional expression saying that only a subset of the rows of the data should be used in the fit
                      weights = NULL,       # optional case (observations) weights
                      na_action = na.rpart, # the default action deletes all observations for which y is missing, but keeps those in which one or more predictors are missing
                      method = "anova",     # # one of "anova", "poisson", "class" or "exp"
                      model = T,            # if logical: keep a copy of the model frame in the result
                      x = F,                # keep a copy of the x matrix in the result
                      y = T,                # keep a copy of the dependent variable in the result. If missing and model is supplied this defaults to FALSE
                      parms = NA,           # optional parameters for the splitting function (e.g. Anova splitting has no parameters)
                      cost = NA,            # a vector of non-negative costs, one for each variable in the model. Defaults to one for all variables
                      minsplit = 45,        # the minimum number of observations that must exist in a node in order for a split to be attempted.
                      minbucket = 15,       # the minimum number of observations in any terminal <leaf> node. (default: round(minsplit/3))
                      cp = 0,               # complexity parameter
                      maxcompete = 4,       # the number of competitor splits retained in the output
                      maxsurrogate = 5,     # the number of surrogate splits retained in the output.
                      usesurrogate = 2,     # how to use surrogates in the splitting process: 0->only display, 1->use surrogate, 2->send observations to the majority node
                      xval = 10,            # number of cross-validations 
                      surrogatestyle = 0,   # controls the selection of a best surrogate: 0 -> number of correct classification, 1-> % of correct classification
                      maxdepth = c(8),      # Set the maximum depth of any node of the final tree, with the root node counted as depth 0.
                      cv_sd_flag = 1        # user-derfined parameter, 0-> optimal cp doesn't consider the sd deviation of the cross-validated error, 1 -> it considers
                      )

# ranger (fast random forest implementation)

ranger_grid <- expand.grid(mtry = 90, 
                           min.node.size = 7, 
                           splitrule = "variance")
                           # importance = "permutation",
                           # write_forest = T,
                           # probability = F,
                           # max.depth = NULL,
                           # replace = T,
                           # sample.fraction = ifelse(T, 1, 0.632),
                           # case.weights = NULL,
                           # class.weights = NULL,
                           # num.random.splits = 1,
                           # alpha = 0.5,
                           # minprop = 0.1,
                           # split.select.weights = NULL,
                           # always.split.variables = NULL,
                           # respect.unordered.factors = NULL,
                           # scale.permutation.importance = F,
                           # local.importance = F,
                           # regularization.factor = 1,
                           # regularization.usedepth = F,
                           # keep.inbag = F,
                           # inbag = NULL,
                           # holdout = F,
                           # quantreg = F,
                           # oob.error = T,
                           # num.threads = NULL,
                           # save.memory = F,
                           # verbose = T,
                           # seed = 13,
                           # dependent.variable.name = NULL,
                           # status.variable.name = NULL,
                           # classification = NULL,
                           # x = NULL,
                           # y = NULL
            
# xgboost

xgboost_grid <- expand.grid(nrounds = 1000,
                            eta = c(0.1, 0.05, 0.01),
                            max_depth = c(2, 3, 4, 5, 6),
                            gamma = 0,
                            colsample_bytree = 1,
                            min_child_weight = c(1, 2, 3, 4 ,5),
                            subsample = 1
                            )

# 3. visualization -------------------------------

# rpart plot
rpart_plot_control <- list(node.fun = NULL, # custom function, options: 1) NULL, 2) plot_custom_box
                           nn = T,
                           varlen = 0,
                           faclen = 0,
                           fallen.leaves = TRUE,
                           roundint = T, 
                           extra = 101, 
                           digits = 3, 
                           type = 2, 
                           box.palette = "Blues",
                           shadow.col = "grey",
                           branch.lty = 3
                           )
