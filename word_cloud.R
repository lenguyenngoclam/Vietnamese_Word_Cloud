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
# Read dataset
db_path <- "./invention_article_contents/"
article_contents_parquet <- arrow::open_dataset(db_path)

# Get sentences vector
senteces <- (article_contents_parquet |> collect())$sentence

# Create corpus
corpus <- tm::VCorpus(tm::VectorSource(senteces))

inspect(corpus[[11]])

# Transform documents
NLP_tokenizer <- function(x) {
  unlist(lapply(ngrams(words(x), 2:4), paste, collapse = "_"), use.names = FALSE)
}

control_list_ngram = list(
  tokenize = NLP_tokenizer,
  removePunctuation = TRUE,
  removeNumbers = TRUE, 
  stopwords = stopwords::stopwords(language="vi",
                                    source="stopwords-iso"), 
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

# Generate word cloud
set.seed(12345) # for reproducibility 
wordcloud(words = df$word,
          freq = df$freq,
          min.freq = 1, 
          random.order = FALSE,
          colors=brewer.pal(8, "Dark2"), 
          scale=c(3.5,0.25))
