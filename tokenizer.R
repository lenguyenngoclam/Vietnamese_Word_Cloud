# # Install required package
# install.packages("reticulate")

library(reticulate)
library(tidyverse)

reticulate::use_condaenv(condaenv = "vietnamese_word_cloud")
spacy <- import("spacy")
nlp <- spacy$load("vi_core_news_lg")

doc <- nlp(
  'Công ty khởi nghiệp Katrick Technologies ở Glasgow đang phát triển một thiết kế \
  mang tính cách mạng là turbine gió không cánh quạt hình tổ ong. Khác với turbine truyền thống,\
  sáng kiến của Katrick Technologies bao gồm các khối hình lục giác nhỏ gọn trông giống tổ ong,\
  đặt trên nóc tòa nhà đô thị hoặc tích hợp với cấu trúc có sẵn,\
  Interesting Engineering hôm 23/12 đưa tin.',
)

print(doc)
l_iterator <- reticulate::as_iterator(doc)
tokens <- reticulate::iterate(l_iterator, f = function(token) token$text)