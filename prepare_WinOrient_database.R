
# Скрипт для подготовки базы результатов соревнований к подсчету очков

# В этом скрипте нужно менять только zs_directory и competitions_date - в самой первой строке

zs_directory <- "~/Dropbox/Orienteering/2017/ZS/"
competitions_date <- "170405"

library(stringr)

# Считываем результаты из .csv для SplitsBrowser
# Для начала выясняем максимальное количество столбцов в файле, так как дистанции с максимальным количетсвом КП могут идти не первыми
max_ncol <- max(count.fields(paste0(zs_directory, competitions_date, ".csv"), sep = ";"))
# Считываем заголовок, добавляем его до нужного числа колонок и дописываем в файл
# Здесь все время предполагаем, что колонки НУЖНО добавлять (если не нужно - решим позже)
# Считываем заголовок
results_header <- read.csv2(file = paste0(zs_directory, competitions_date, ".csv"), header = FALSE, nrows = 1, colClasses = "character", stringsAsFactors = FALSE)
# Определяем, сколько не хватает колонок
cols_to_add <- max_ncol - ncol(results_header) + 1
# Колонки до 66 всегда заполнены правильно, нужно добавлять начиная с 67
names_to_add <- paste0(c("Control", "Punch"), rep(1:(cols_to_add/2)+10, each = 2))
# Последняя колонка в results_header имеет вид "(may be more) ...", ее нужно вырезать
results_header[ , ncol(results_header)] <- NULL
# Окончательно присоединяем заголовок
results_header <- c(results_header[1, ], names_to_add)

# Теперь считываем весь файл построчно, заменяем заголовок и записываем назад (я знаю, что это не очень круто! Но пока другого выхода не вижу)
results <- readLines(con = paste0(zs_directory, competitions_date, ".csv"))
# Заменяем все пробелы в именах переменных на подчеркивания, так с ними легче работать
# В конце добавляем еще одну запятую - так как все строки оригинального файла содержат ее
results[1] <- paste0(str_replace_all(paste0(results_header, collapse = ";"), " ", "_"), ";")
writeLines(text = results, con = paste0(zs_directory, competitions_date, "_with_correct_header.csv"))

# Теперь можно просто по-человечески считывать полученный файл и колонки должны прочитаться красиво
results <- read.csv2(file = paste0(zs_directory, competitions_date, "_with_correct_header.csv"), header = TRUE, stringsAsFactors = FALSE)

# Убираем последнюю колонку - похоже, она всегда будет пустой
results[ , ncol(results)] <- NULL

# Убираем ненужные колонки
results$Database_Id <- NULL
results$First_name <- NULL
results$S <- NULL
results$Block <- NULL
results$nc <- NULL
results$Classifier <- NULL
results$Club_no. <- NULL
results$Cl.name <- NULL
results$City <- NULL
results$Nat <- NULL
results$Cl._no. <- NULL
results$Long <- NULL
results$Num1 <- NULL
results$Num2 <- NULL
results$Num3 <- NULL
results$Text1 <- NULL
results$Text2 <- NULL
results$Text3 <- NULL
results$Adr._name <- NULL
results$Street <- NULL
results$Line2 <- NULL
results$Zip <- NULL
results$City.1 <- NULL # Странно, не могу понять, почему появляется 1, виимо, из-за оинакового названия двух столбцов.
results$Phone <- NULL
results$Fax <- NULL
results$EMail <- NULL
results$Id.Club <- NULL
results$Rented <- NULL
results$Start_fee <- NULL
results$Paid <- NULL
results$Course_no. <- NULL

# Так как на ЗС у нас старт только по стартовой станции, время старта и время финиша всегда совпадают со временами отметки в соответствующих станциях
all.equal(results$Start, results$Start_punch)
all.equal(results$Finish, results$Finish_punch)

results$Start <- NULL
results$Finish <- NULL

# Заменяем все пустые строки на NA
results[is.na(results)] <- ""

# В общем, в таком виде результаты готовы для обработки, по крайней мере для ЗСа этого точно будет достаточно
write.csv2(x = results, file = paste0(zs_directory, competitions_date, "_cleaned.csv"), row.names = FALSE)
