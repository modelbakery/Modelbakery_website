###################
# how to return back from gather and spread
###################

Boston_transform %>% 
  gather(key = var_name, value = var_value) %>% 
  group_by(var_name) %>% 
  mutate(outlier_flag = detect_outliers(var_value),
         outlier_flag = ifelse(outlier_flag == TRUE, 1, 0),
         grouped_id = row_number()) %>% ungroup() %>% 
  select(var_name, outlier_flag, grouped_id) %>% 
  spread(var_name, outlier_flag) %>% 
  mutate()

spread(var_name, var_value) %>% 
  select(-grouped_id)


Boston_outlier_tbl <- Boston_transform %>% 
  mutate_all(funs(x = detect_outliers(.))) %>% 
  mutate_if(is.logical, as.numeric) %>% 
  mutate(outlier_flag = rowSums(.[grep("_x", names(.))], na.rm = TRUE)) %>% 
  mutate(row_id = row_number(),
         cooksd_flag = case_when(row_id %in% influential ~ 1,
                                 TRUE ~0)) %>%
  
  mutate(outlier_inves        = case_when(outlier_flag > 0 & cooksd_flag == 1 ~ TRUE,
                                          TRUE ~ FALSE),
         outlier_treat_w_mean = case_when(outlier_flag == 0 & cooksd_flag > 0 ~ TRUE,
                                          TRUE ~ FALSE),
         outlier_treat_w_IQR  = case_when(outlier_flag > 0 & cooksd_flag == 0 ~ TRUE,
                                          TRUE ~ FALSE)) %>% 
  select(row_id, everything()) %>% 