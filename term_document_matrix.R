# # Install required package
# install.packages("RColorBrewer")
# install.packages("wordcloud")
# install.packages("tm")
# install.packages("arrow")
# install.packages("stopwords")
# install.packages("tokenizers")
library(tokenizers)
library(wordcloud)
library(RColorBrewer)
library(tm)
library(arrow)
library(tidyverse)
library(stopwords)
# Get tokenizer
source("./tokenizer.R")

# Read dataset
invention_article_contents_parquets <- arrow::open_dataset(sources = "./invention_article_contents/")
application_article_contents_parquets <- arrow::open_dataset(sources = "./application_article_contents/")
news_article_contents_parquets <- arrow::open_dataset(sources = "./news_article_contents/")
article_contents_parquet <- rbind(
  invention_article_contents_parquets |> collect(), 
  application_article_contents_parquets |> collect(),
  news_article_contents_parquets |> collect()
)
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
df |> arrow::write_dataset(path="term_document_matrix", format = "parquet")

# Clear enviroment
rm(list = ls())