library(data.table)
library(httr)

# Set logging level
log_level <- "info"

# Logging function
log <- function(level, message) {
  timestamp <- format(Sys.time(), "%y-%m-%d %H:%M:%S")
  cat(paste0(timestamp, " [", level, "] ", message, "\n"))
}

url <- "https://www.envidat.ch/dataset/d6c7a578-6317-49f3-8ba5-71f62b5b6610/resource/0aca99e1-7b3d-492f-a7bb-2756e5b74bbd/download/events.csv"

log(log_level, paste0("Reading csv file into data frame from url: ", url))
response <- GET(url)
content <- content(response, as = "text")
df <- fread(content, encoding = "UTF-8")

log(log_level, "Transposing data frame")
df <- t(df)

output_dir <- file.path(getwd(), "output")
log(log_level, paste0("Creating output dir: ", output_dir))
dir.create(output_dir, recursive = TRUE)
system(paste("chmod 777", shQuote(output_dir)), ignore.stderr = TRUE)

file_path <- file.path(output_dir, "processed.csv")
log(log_level, paste0("Deleting output file if already exists: ", file_path))
if (file.exists(file_path)) {
  file.remove(file_path)
}

log(log_level, "Writing output csv to file")
fwrite(df, file_path)
system(paste("chmod 777", shQuote(file_path)), ignore.stderr = TRUE)
