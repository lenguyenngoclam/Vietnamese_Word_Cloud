import spacy
nlp = spacy.load('vi_core_news_lg')
doc = nlp(
  'Công ty khởi nghiệp Katrick Technologies ở Glasgow đang phát triển một\
  thiết kế mang tính cách mạng là turbine gió không cánh quạt hình tổ ong.\
  Khác với turbine truyền thống, sáng kiến của Katrick Technologies bao gồm các \
  khối hình lục giác nhỏ gọn trông giống tổ ong, đặt trên nóc tòa nhà đô thị \
  hoặc tích hợp với cấu trúc có sẵn, Interesting Engineering hôm 23/12 đưa tin.')
print(doc)
for token in doc:
    print(token.text, token.lemma_, token.pos_, token.tag_, token.dep_,
            token.shape_, token.is_alpha, token.is_stop)
