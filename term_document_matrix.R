# # Install required package
# install.packages("RColorBrewer")
# install.packages("wordcloud")
# install.packages("tm")
# install.packages("arrow")
# install.packages("stopwords")
# install.packages("tokenizers")
library(optparse)
library(tokenizers)
library(wordcloud)
library(RColorBrewer)
library(tm)
library(arrow)
library(tidyverse)
library(stopwords)
# Get tokenizer
source("./tokenizer.R")

option_list <- list(
  make_option(c("--dataset_path"),
              default = "./temp",
              help = "Dataset path.
                      The dataset has to be stored in parquet format."),
  make_option(c("--store_path"),
              default = "./temp_tm_matrix",
              help = "Term-document matrix store path")
)
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$dataset_path) | is.null(opt$store_path)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

# Read dataset
article_contents_parquet <- arrow::open_dataset(sources = opt$dataset_path) |> collect()
# Get sentences vector
sentences <- article_contents_parquet$sentence

# Create corpus
corpus <- tm::VCorpus(tm::VectorSource(sentences))

inspect(corpus[[11]])

# Transform documents
control_list_ngram = list(
  tokenize = spacy_tokenizer,
  removePunctuation = TRUE,
  removeNumbers = TRUE, 
  stopwords = get_stopwords(method="spacy"), 
  tolower = TRUE, 
  stemming = FALSE, 
  weighting = function(x)
  weightTf(x)
)

# Create term-document matrix 
dtm <- tm::TermDocumentMatrix(corpus, control_list_ngram) 
matrix <- as.matrix(dtm) 
words <- sort(rowSums(matrix),decreasing=TRUE) 
df <- tibble(word = names(words),freq=words)

# Store term-document matrix
df |> arrow::write_dataset(path=opt$store_path, format = "parquet")

# Clear enviroment
rm(list = ls())