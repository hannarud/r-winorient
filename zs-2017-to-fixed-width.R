
# Скрипт для вывода результатов в fixed width table для размещения на ОБеларусь

# В этом скрипте нужно менять только competitions_date - в самой первой строке

competitions_date <- "170412"

results_score <- read.csv2(file = paste0(competitions_date, "_scores.csv"), header = TRUE, stringsAsFactors = FALSE, encoding = "UTF-8")

library(gdata)
library(dplyr)

results_score <- as.data.frame(group_by(results_score, Short, Pl))

write.fwf(x = results_score[, c("Pl", "Surname", "Time", "Score")], file = paste0(competitions_date, "_scores_plain_text.txt"),
          sep = " ", na = " ", rownames = FALSE, colnames = FALSE,
          width = c(4, 27, 9, 4))
