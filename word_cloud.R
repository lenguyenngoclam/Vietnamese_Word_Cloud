# # Install required package
# install.packages("RColorBrewer")
# install.packages("wordcloud")
# install.packages("arrow")

library(wordcloud)
library(RColorBrewer)
library(arrow)
library(tidyverse)

# Load term document matrix
df <- arrow::open_dataset(sources = "./term_document_matrix") |> collect()

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