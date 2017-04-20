
# В этом скрипте нужно менять только zs_directory - в самой первой строке

zs_directory <- "~/Dropbox/Orienteering/2017/ZS/"

dates <- c("170405", "170409", "170412")

# Считываем файл регистрации по состоянию на последнюю дату - он самый полный
zs_register <- read.csv2(file = paste0(zs_directory, dates[length(dates)], "_zs2017.csv"), header = TRUE, stringsAsFactors = FALSE)

library(dplyr)

for(i in dates) {
  scores_i <- read.csv2(file = paste0(zs_directory, i, "_scores.csv"), header = TRUE, stringsAsFactors = FALSE)
  scores_i <- select(scores_i, Stno, Score)
  names(scores_i) <- c("Stno", paste0("Score_", i))
  zs_register <- left_join(zs_register, scores_i, by = c("number" = "Stno"))
  # zs_register[[paste0("Score_", i)]][is.na(zs_register[[paste0("Score_", i)]])] <- 0
  rm(scores_i)
}

zs_register$Score_sum <- rowSums(select(zs_register, starts_with("Score_")), na.rm = TRUE)

write.csv2(x = results, file = paste0(zs_directory, "zs_sum_after_" competitions_date, ".csv"), row.names = FALSE, fileEncoding = "UTF-8")