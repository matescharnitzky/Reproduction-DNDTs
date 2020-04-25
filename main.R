

# 1. setup envrionment ----------------------------

# load packages
source("./src/load_packages.R")

# load configuraiton
source("./config/config.R")

# load source code
source("./src/utils.R")
source("./src/process_data.R")
source("./src/run_lm.R")
source("./src/run_rpart.R")
source("./src/run_ranger.R")

# 2. read data ------------------------------------

# input data (train + test)
raw_df <- list(train_file, test_file) %>% 
  purrr::set_names(nm = "train", "test") %>% 
  map(read_csv) %>% 
  bind_rows(.id = "data_type")

# mapping file
mapping_df <- parse_txt(mapping_file) %>% 
  filter(level_code != "")

# 3. prepare data ---------------------------------

# create processed data
input_list <- process_data(raw_df = raw_df, 
                           mapping_df = mapping_df)

# training data
train_df <- input_list[["proc_df"]] %>% 
  filter(data_typetrain == 1) %>% 
  select(-c(data_typetrain, id))

X_train <- train_df %>% 
  select(-!!sym(target_var))

y_train <- train_df[[target_var]]

# test data
test_df <- input_list[["proc_df"]] %>% 
  filter(data_typetrain == 0) %>% 
  select(-c(data_typetrain, id))

X_test <- test_df %>% 
  select(-!!sym(target_var))

y_test <- test_df[[target_var]]

# test IDs
test_id <- input_list[["input_df"]] %>% 
  filter(data_type == "test") %>% 
  select(id) %>% 
  pull

# 4. Run: linear model ----------------------------

# run model
lm_list <- run_lm(X_train = X_train,
                  y_train = y_train,
                  X_test = X_test,
                  y_test = y_test,
                  train_control = train_control,
                  lm_grid = lm_grid)

# model summary
lm_list[["model"]]

# train r2
lm_list[["train_r2"]]

# save submission
write_csv(x = lm_list[["submission_df"]], 
          path = str_c("./models/lm_submission_", format(Sys.time(), format = "%Y%m%d%_%H%M"), ".csv"))

# 4. Run: rpart model -----------------------------

# run model
rpart_list <- run_rpart(train_df = train_df, 
                        test_df = test_df, 
                        rpart_control = rpart_control)

# model summary
summary(rpart_list[["model"]])

# train r2
rpart_list[["train_r2"]]

# cp
rpart_list[["optimal_cp"]]

# plot variable importance
plot_variable_importance(variable = names(rpart_list[["model"]][["variable.importance"]]),
                         score = rpart_list[["model"]][["variable.importance"]], 
                         top_n = NA,
                         scale = T, model_type = "RPART")
  
# plot tree
prp(x = rpart_list[["model"]], 
    sub = "",
    main = "Decision Tree - RPART",
    prefix = str_c(target_var,"="),
    nn = rpart_plot_control[["nn"]],
    varlen = rpart_plot_control[["varlen"]],
    faclen = rpart_plot_control[["faclen"]],
    fallen.leaves = rpart_plot_control[["fallen.leaves"]],
    roundint = rpart_plot_control[["roundint"]], 
    extra = rpart_plot_control[["extra"]], 
    digits = rpart_plot_control[["digits"]], 
    type = rpart_plot_control[["type"]], 
    box.palette = rpart_plot_control[["box.palette"]], 
    node.fun = rpart_plot_control[["node.fun"]], 
    shadow.col = rpart_plot_control[["shadow.col"]],
    branch.lty = rpart_plot_control[["branch.lty"]])

# save submission
write_csv(x = rpart_list[["submission_df"]], 
          path = str_c("./models/rpart_submission_", format(Sys.time(), format = "%Y%m%d%_%H%M"), ".csv"))

# 5. Run: ranger model ----------------------------

# run model
ranger_list <- run_ranger(X_train = X_train,
                          y_train = y_train,
                          X_test = X_test,
                          y_test = y_test,
                          train_control = train_control,
                          ranger_grid = ranger_grid)

# model summary
ranger_list[["model"]]

# train r2
ranger_list[["train_r2"]]

# plot variable importance
plot_variable_importance(variable = rownames(varImp(ranger_list[["model"]], scale = F)[["importance"]]),
                         score = varImp(ranger_list[["model"]], scale = F)[["importance"]][["Overall"]], 
                         scale = T, 
                         top_n = 50,
                         model_type = "Ranger")

# save submission
write_csv(x = ranger_list[["submission_df"]], 
          path = str_c("./models/ranger_submission_", format(Sys.time(), format = "%Y%m%d%_%H%M"), ".csv"))

# 6. Run: ranger model ----------------------------

# run model
xgboost_list <- run_xgboost(X_train = X_train,
                            y_train = y_train,
                            X_test = X_test,
                            y_test = y_test,
                            train_control = train_control,
                            xgboost_grid = xgboost_grid, 
                            mean = input_list[["pp_model"]][["mean"]][["saleprice"]], 
                            sd = input_list[["pp_model"]][["std"]][["saleprice"]])

# model summary
xgboost_list[["model"]]

# train r2
xgboost_list[["train_r2"]]

# save submission
write_csv(x = xgboost_list[["submission_df"]], 
          path = str_c("./models/xgboost_submission_", format(Sys.time(), format = "%Y%m%d%_%H%M"), ".csv"))
