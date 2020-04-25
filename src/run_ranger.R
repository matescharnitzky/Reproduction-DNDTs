

run_ranger <- function(X_train,
                       y_train,
                       X_test,
                       y_test,
                       train_control,
                       ranger_grid) {
  # set seed
  set.seed(13)
  
  # initialize list
  result_list <- list()
  
  # fit model
  result_list[["model"]] <- train(x = X_train, 
                                  y = y_train, 
                                  method = "ranger", 
                                  trControl = train_control, 
                                  tuneGrid = ranger_grid,
                                  importance = "permutation", 
                                  seed = 13)

  # calculate train r2
  result_list[["train_r2"]] <- calc_r2(actual = y_train, 
                                       prediction = predict(object = result_list[["model"]], 
                                                            newdata = X_train))
  
  # predict on test data, if missing impute with avg
  result_list[["prediction"]] <- predict(object = result_list[["model"]], newdata = X_test)
  
  # submission df
  result_list[["submission_df"]] <- data.frame(Id = test_id,
                                               SalePrice = exp(result_list[["prediction"]]))
  
  # output
  return(result_list)
  
}
