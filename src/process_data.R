

process_data <- function(raw_df, mapping_df) {
  
  # 1. recode columns -----------------------------
  
  column_list <- names(raw_df)
  
  input_df <- raw_df %>% 
    # list of columns
    map(function(x) x) %>%
    # recode columns 1 by 1
    map2(.y = column_list, .f = ~recode_columns(mapping_df, col = .x, col_name = .y)) %>% 
    # lists of vectors to df
    data.frame(stringsAsFactors = F)
    
  # 2. format columns -----------------------------
  
  colnames(input_df) <- format_cols(cols = colnames(input_df))
  
  # 3. handle missing values ----------------------
  input_df <- input_df %>% 
    mutate_all(~ifelse(is.na(.) & is.numeric(.), 0, 
                ifelse(is.na(.) & is.character(.), "NA", .)))
  
  # 4. categorical variables: one hot encoding ----
  
  # character df
  char_df <- input_df %>% 
    select_if(is.character)
  
  # create dummies
  char_df <- model.matrix(~ ., char_df) %>% 
    as.data.frame()
  
  # 5. numeric variables: normalize ---------------
  
  # target variable: log transformation
  target_log <- log(input_df[[target_var]])
  
  # numeric df
  num_df <- input_df %>% 
    select(-!!sym(target_var)) %>% 
    select_if(is.numeric)
  
  # build preprocess model
  pp_model <- preProcess(num_df, method = c("center", "scale"))
  
  # normalize
  num_df <- predict(pp_model, num_df)
  
  # compile
  proc_df <- cbind(char_df, num_df) %>% 
    mutate(!!sym(target_var) := target_log)
  
  # 6. output -------------------------------------
  return(list(input_df = input_df, proc_df = proc_df, pp_model = pp_model))
}
