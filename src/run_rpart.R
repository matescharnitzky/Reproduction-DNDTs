

run_rpart <- function(train_df, test_df, rpart_control) {
  # set seed
  set.seed(13)
  
  # initialize list
  result_list <- list()
  
  # fit model
  result_list[["model"]] <- rpart(data = train_df, 
                                  formula = saleprice ~ .,
                                  weights = rpart_control[["weights"]],
                                  subset = rpart_control[["subset"]], 
                                  na.action = rpart_control[["na_action"]],
                                  method = rpart_control[["method"]], 
                                  model = rpart_control[["model"]], 
                                  x = rpart_control[["x"]], 
                                  y = rpart_control[["y"]], 
                                  parms = rpart_control[["parms"]], 
                                  control = rpart.control(minsplit = rpart_control[["minsplit"]],
                                                          minbucket = rpart_control[["minbucket"]],
                                                          cp = rpart_control[["cp"]],
                                                          maxcompete = rpart_control[["maxcompete"]],
                                                          maxsurrogate = rpart_control[["maxsurrogate"]],
                                                          usesurrogate = rpart_control[["usesurrogate"]],
                                                          xval = rpart_control[["xval"]],
                                                          surrogatestyle = rpart_control[["surrogatestyle"]],
                                                          maxdepth = rpart_control[["maxdepth"]]), 
                                  cost = rep(1, ncol(train_df) -1))
  
  # find optimal cp
  result_list[["optimal_cp"]] <- find_optimal_cp(cptable = result_list[["model"]][["cptable"]], 
                                                 cv_sd_flag = rpart_control[["cv_sd_flag"]])
  
  # prune tree to optimal cp
  result_list[["model"]] <- prune.rpart(tree = result_list[["model"]], cp = result_list[["optimal_cp"]])
  
  # calculate train r2
  result_list[["train_r2"]] <- calc_r2(actual = train_df[["saleprice"]], 
                                       prediction = predict(object = result_list[["model"]], 
                                                            newdata = train_df))
  # predict on test data, if missing impute with avg
  result_list[["prediction"]] <- predict(object = result_list[["model"]], 
                                         newdata = remove_missing_levels(model = result_list[["model"]], 
                                                                         test_df = test_df))
  
  result_list[["prediction"]] <- ifelse(is.na(result_list[["prediction"]]), 
                                        mean(train_df[[target_var]]), 
                                        result_list[["prediction"]]) 
  
  # submission df
  result_list[["submission_df"]] <- data.frame(Id = test_id,
                                               SalePrice = result_list[["prediction"]])
  
  # output
  return(result_list)
  
}
