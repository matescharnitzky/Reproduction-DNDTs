
# Function: Format Columns

format_cols <- function(cols) {
  
  # format cols
  formatted_cols <- cols %>% 
    # to lower case
    str_to_lower() %>% 
    # eliminate white space, special characters...etc.
    str_replace_all(pattern = " ", replacement = "_") %>%
    str_replace_all(pattern = "\\.", replacement = "_") %>%
    str_replace_all(pattern = "\\,", replacement = "_") %>%
    str_replace_all(pattern = "\\-", replacement = "_") %>% 
    str_replace_all(pattern = "\\(", replacement = "") %>% 
    str_replace_all(pattern = "\\)", replacement = "") %>%
    str_replace_all(pattern = "\\%", replacement = "pct") %>% 
    str_replace_all(pattern = "\\$", replacement = "usd") %>%
    str_replace_all(pattern = "\\?", replacement = "") %>% 
    str_replace_all(pattern = "\\!", replacement = "") %>%
    str_replace_all(pattern = "\\#", replacement = "") %>% 
    # add an "_" if starting with a numeric
    str_replace(pattern = "(^\\d+)(.*)", replacement = "col_\\1\\2")
  
  # return formatted cols
  return(formatted_cols)
  
}

# Function: Parse TXT File

parse_txt <- function(path) {
  # reading txt by lines
  mapping_txt <- readLines(path)
  
  # parameters 
  n_row <- length(mapping_txt)
  flag <- rep(1, n_row)
  var_name <- vector(mode = "character", length = n_row)
  var_desc <- vector(mode = "character", length = n_row)
  level_code <- vector(mode = "character", length = n_row)
  level_desc <- vector(mode = "character", length = n_row)
  
  # parse rows
  for (i in seq_along(mapping_txt)) {
    # if blank row then skip
    if (mapping_txt[i] %in%  c("\t\t", "", "\t", "       \t", "       ", "\t\t\t", " ")) {
      flag[i] <- 0
    }
    # parsing variable name and description
    if (str_detect(mapping_txt[i], "^\\w*: .*")) {
      #flag[i] <- 0
      var_name[i] <- str_trim(str_split(string = mapping_txt[i], pattern = ":")[[1]][1])
      var_desc[i] <- str_trim(str_split(string = mapping_txt[i], pattern = ":")[[1]][2])
      # parsing variable levels
    } else {
      var_name[i] <- var_name[i - 1]
      var_desc[i] <- var_desc[i - 1]
      level_code[i] <- str_trim(str_split(string = mapping_txt[i], pattern = "\t")[[1]][1])
      level_desc[i] <- str_split(string = mapping_txt[i], pattern = "\t")[[1]][2]
    }
  }
  
  # bind columns into a dataframe
  output_df <- bind_cols(flag = flag, 
                         variable_name = var_name,
                         variable_description = var_desc,
                         level_code = level_code,
                         level_description = level_desc) %>%
    filter(flag == 1) %>% 
    select(-flag)
  
  # output
  return(output_df)
  
}

# Function: recode columns

recode_columns <- function(mappin_df, col, col_name) {
  # recode
  if (col_name %in% unique(mapping_df[["variable_name"]])) {
    recoded_col <- plyr::mapvalues(x = col,
                                   from = mapping_df[mapping_df[["variable_name"]] == col_name, "level_code", drop = T],
                                   to = mapping_df[mapping_df[["variable_name"]] == col_name, "level_description", drop = T], 
                                   warn_missing = F) %>% 
      as.character()
  } else{
    recoded_col <- col
  }
  
  # output
  return(recoded_col)
}

# Function: Calculate R2

calc_r2 <- function(actual, prediction) {
  
  # residual sum of squares
  rss <- sum((prediction - actual)^2)  
  
  # total sum of squares
  tss <- sum((actual - mean(actual))^2)  ## total sum of squares
  
  # r2
  r2 <- 1 - rss/tss
  
  # output
  return(r2)
}

# Function: remove missing levels

remove_missing_levels <- function(model, test_df) {
  
  # drop empty factor levels in test data
  test_df <- test_df %>%
    droplevels()
  
  # do nothing if no factors are present
  if (length(model[["xlevels"]]) == 0) {
    return(test_df)
  }
  
  # extract model factors and levels
  model_factors_df <- map2(.x = names(model$xlevels), 
                           .y = model$xlevels, 
                           .f = function(factor, levels) data.frame(factor, levels, stringsAsFactors = F)) %>% 
    bind_rows()
  
  # select column names in test data that are factor predictors in trained model
  predictors <- names(test_df[names(test_df) %in% model_factors_df[["factor"]]])
  
  # for each factor predictor in your data, if the level is not in the model set the value to NA
  for (i in seq_along(predictors)) {
    
    # identify model levels
    model_levels <- model_factors_df[model_factors_df[["factor"]] == predictors[i], "levels", drop = T]
    
    # identify test levels
    test_levels <- test_df[, predictors[i]] 
    
    # found flag
    found_flag <- test_levels %in% model_levels
    
    # if any missing, then set to NA
    if (any(!found_flag)) {
      
      # missing levels
      missing_levels <- str_c(as.character(unique(test_levels[!found_flag])), collapse = ",")
      
      # set to NA
      test_df[!found_flag, predictors[i]] <- NA
      
      # drop empty factor levels in test data
      test_df <- test_df %>%
        droplevels()
      
      # message console
      message(glue("In {predictors[i]}: setting missing level(s) {missing_levels} to NA"))
      
    }
  }
  
  # output
  return(test_df)
}

# Function: find optimal cp

find_optimal_cp <- function(cptable, cv_sd_flag) {
  
  # define the minimum cross-validated error
  index_min_error <- which.min(cptable[, 4])
  
  # min error
  min_error <- cptable[index_min_error, 4]
  
  # min error sd
  sd_min_error <- cptable[index_min_error, 5]
  
  # optimum line
  if (cv_sd_flag == 1) {
    optimal_line <- min_error + sd_min_error  
  } else {
    optimal_line <- min_error  
  }
  
  # optimal cp index
  optimal_cp_index <- which.min(abs((cptable[, 4] - optimal_line)))
  
  # optimal cp
  optimal_cp <- cptable[optimal_cp_index, 1]
  
  # output
  return(optimal_cp)
  
}

# Function: plot variable importance

plot_variable_importance <- function(variable, score, scale = T, top_n, model_type) {
  
  # scale if needed
  if (scale == T) {
    score <- score/sum(score) * 100
  }
  
  # create data frame
  importance_df <- data.frame(variable, score) %>% 
    arrange(desc(score))
  
  # filter
  if (!is.na(top_n)) {
    importance_df <- importance_df[1:top_n, ]
  }
  
  # plot
  ggplot(data = importance_df, mapping = aes(x = reorder(variable, score), y = score)) + 
    geom_bar(stat = "identity") +
    #labs(title = "Variable Importance - RANGER") +
    ggtitle(label = str_c("Variable Importance", model_type, sep = " - ")) +
    xlab("variable") +
    ylab("importance scores in %") +
    coord_flip()
}
