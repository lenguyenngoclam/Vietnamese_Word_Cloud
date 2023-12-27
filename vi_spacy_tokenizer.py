import spacy
from spacy.lang.vi import stop_words as stop_words
nlp = spacy.load('vi_core_news_lg')

def get_stop_words():
  return list(map(lambda text: text.replace("_", " "), stop_words.STOP_WORDS))

def tokenize(text):
  doc = nlp(text)
  for token in doc:
    print(token.text, token.lemma_, token.pos_, token.tag_, token.dep_,
              token.shape_, token.is_alpha, token.is_stop)
