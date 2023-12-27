# # Install required package
# install.packages("reticulate")
# install.packages("tm")

library(reticulate)
library(tidyverse)
library(tm)

# Connect to conda enviroment
reticulate::use_condaenv(condaenv = "vietnamese_word_cloud")
spacy <- import("spacy")
nlp <- spacy$load("vi_core_news_lg")

spacy_tokenizer <- function(text) {
  doc <- nlp(text$content)
  iterator <- reticulate::as_iterator(doc)
  tokens <- reticulate::iterate(iterator, f = function(token) token$text)
  return (tokens)
}

# Transform documents
ngram_tokenizer <- function(text) {
  tokens <- unlist(lapply(ngrams(words(text), 2:4), paste, collapse = " "), use.names = FALSE)
  return (tokens)
}

get_stopwords <- function(method="spacy"){
  if (method == "spacy"){
    reticulate::source_python("./vi_spacy_tokenizer.py")
    stop_words <- get_stop_words()
  } else {
    stop_words <- stopwords::stopwords(language="vi",
                                       source="stopwords-iso")
  }
  return (stop_words)
}
