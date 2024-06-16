require_relative 'word_2_vec.rb'


@corpus = [
  "the quick brown fox jumps over the lazy dog",
  "the dog barks at the moon",
  "the fox is quick and the dog is lazy"
]

word2vec = Word2Vec.new(@corpus)
word2vec.train

