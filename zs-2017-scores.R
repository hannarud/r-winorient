
# Скрипт для подсчета очков на ЗС-2017

# В этом скрипте нужно менять только competitions_date - в самой первой строке

competitions_date <- "170412"

results <- read.csv2(file = paste0(competitions_date, "_cleaned.csv"), header = TRUE, stringsAsFactors = FALSE)
zs_register <- read.csv2(file = "zs2017.csv", header = TRUE, stringsAsFactors = FALSE)
# courses <- read.csv2(file = paste0(competitions_date, "_courses.txt"), header = TRUE, stringsAsFactors = FALSE)

# TODO: добавить модуль проверки правильности отметки, пока просто полагаемся на предоставленное из SI

# Удаляем все неофициальные дистанции

# 1 тур
# results <- results[results$Course %in% c("Д - 1", "Д - 2", "Д - 3", "Д - 4", "Д - 5", "Д - 6", "Д - 7"), ]
# 2 тур
# results <- results[results$Course %in% c("Д1", "Д2", "Д3", "Д4", "Д5", "Д6", "Д7"), ]
# 3 тур
results <- results[results$Course %in% c("velo", "Д1", "Д2", "Д3", "Д4", "Д5", "Д6", "Д7"), ]

# Добавляем каждому участнику время прохождения дистанции в секундах и скорость в метрах в секунду
results$Time_in_sec <- as.integer(as.POSIXct(paste0("1970-01-01 ", results$Time), format = "%Y-%m-%d %H:%M:%S",
                                             origin = "1970-01-01", tz = "UTC"))
results$Speed_m_sec <- results$km/results$Time_in_sec

# Ищем эталонную женскую скорость как среднюю из 5 лучших на Д1, Д2, Д3 (и не снятых!)
women123 <- results[results$Short %in% c("Ж1", "Ж2", "Ж3") & results$Pl %in% 1:5 & results$Pl != 0, ]

women_etalon_speed <- mean(women123$Speed_m_sec)

# Ищем эталонную мужскую скорость как среднюю из 5 лучших на Д1, Д2, Д3
men123 <- results[results$Short %in% c("М1", "М2", "М3") & results$Pl %in% 1:5 & results$Pl != 0, ]

men_etalon_speed <- mean(men123$Speed_m_sec)

# 1 тур
# coef <- data.frame(dist = c("Д - 1", "Д - 2", "Д - 3", "Д - 4", "Д - 5", "Д - 6", "Д - 7"), coef = c(100, 80, 60, 45, 64, 40, 34))

# 2 тур
# coef <- data.frame(dist = c("Д1", "Д2", "Д3", "Д4", "Д5", "Д6", "Д7"), coef = c(100, 75, 65, 42, 37, 27, 20))

# 3 тур
coef <- data.frame(dist = c("velo", "Д1", "Д2", "Д3", "Д4", "Д5", "Д6", "Д7"), coef = c(0, 100, 92, 78, 57, 40, 30, 20))

results$Score <- apply(results, 1, FUN = function(x) {
  if(as.integer(x[["Pl"]]) == 0){
    return(0)
  } else {
    if(startsWith(x[["Short"]], "Ж")) {
      return(round(coef$coef[coef$dist == x[["Course"]]]*as.double(x[["Speed_m_sec"]])/women_etalon_speed))
    } else {
      return(round(coef$coef[coef$dist == x[["Course"]]]*as.double(x[["Speed_m_sec"]])/men_etalon_speed))
    }
  }
})

write.csv2(x = results, file = paste0(competitions_date, "_scores.csv"), row.names = FALSE, fileEncoding = "UTF-8")
