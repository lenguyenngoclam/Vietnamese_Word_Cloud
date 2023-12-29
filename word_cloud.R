# # Install required package
# install.packages("RColorBrewer")
# install.packages("wordcloud")
# install.packages("arrow")

library(optparse)
library(wordcloud)
library(RColorBrewer)
library(arrow)
library(tidyverse)

option_list <- list(
  make_option(c("--tm_path"),
              default = "./temp_tm_matrix",
              help = "Term-document matrix path. 
                      Have to be stored in parquet format"),
  make_option(c("--output_path"),
              default = "./word_cloud.png",
              help = "Word cloud image output path")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$tm_path) | is.null(opt$output_path)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

# Load term document matrix
df <- arrow::open_dataset(sources = opt$tm_path) |> collect()

# Generate word cloud
set.seed(12345) # for reproducibility 
wordcloud(words = df$word,
          freq = df$freq,
          min.freq = 1,
          max.words = 300,
          random.order = FALSE,
          colors=brewer.pal(8, "Dark2"), 
          scale=c(3.5,0.5))

rm(list = ls())