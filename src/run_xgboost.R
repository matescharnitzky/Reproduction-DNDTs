

run_xgboost <- function(X_train,
                        y_train,
                        X_test,
                        y_test,
                        xgboost_control,
                        mean,
                        sd) {
  # set seed
  set.seed(13)
  
  # initialize list
  result_list <- list()

  # train-validation set split
  result_list[["train_index"]] <- createDataPartition(y = y_train, 
                                                      times = 1, 
                                                      p = 1- validation_pct, 
                                                      list = F)
  
  # train set
  X_train_08 <- X_train[result_list[["train_index"]], ]
  y_train_08 <- y_train[result_list[["train_index"]]]
  
  # validation set
  X_validation <- X_train[-result_list[["train_index"]], ]
  y_validation <- y_train[-result_list[["train_index"]]]
  
  # create xgboost specific data formats
  X_train_dxgb <- xgb.DMatrix(data = as.matrix(X_train), label = y_train)
  X_train_08_dxgb <- xgb.DMatrix(data = as.matrix(X_train_08), label = y_train_08)
  X_validation_dxgb <- xgb.DMatrix(data = as.matrix(X_validation), label = y_validation)
  X_test_dxgb <- xgb.DMatrix(data = as.matrix(X_test))
  
  # fit model
  result_list[["model"]] <- xgb.train(data = X_train_08_dxgb,
                                      watchlist = list(train = X_train_08_dxgb, validation = X_validation_dxgb), 
                                      eval_metric = xgboost_control[["eval_metric"]],
                                      booster = xgboost_control[["booster"]],
                                      objective = xgboost_control[["objective"]],
                                      nrounds = xgboost_control[["nrounds"]],
                                      max_depth = xgboost_control[["max_depth"]],
                                      eta = xgboost_control[["eta"]], 
                                      gamma = xgboost_control[["gamma"]],
                                      colsample_by_tree = xgboost_control[["colsample_by_tree"]],
                                      min_child_weight = xgboost_control[["min_child_weight"]],
                                      subsample = xgboost_control[["subsample"]],
                                      verbose = xgboost_control[["verbose"]], 
                                      print_every_n = xgboost_control[["print_every_n"]],
                                      early_stopping_rounds = xgboost_control[["early_stopping_rounds"]],
                                      maxmize = xgboost_control[["maxmize"]])
  
  # calculate train r2
  result_list[["train_r2"]] <- calc_r2(actual = y_train, 
                                       prediction = predict(object = result_list[["model"]], 
                                                            newdata = X_train_dxgb))
  
  # predict on test data, if missing impute with avg
  result_list[["prediction"]] <- predict(object = result_list[["model"]], newdata = X_test_dxgb)
  
  # submission df
  result_list[["submission_df"]] <- data.frame(Id = test_id,
                                               SalePrice = exp(result_list[["prediction"]]))
  
  # output
  return(result_list)
  
}
