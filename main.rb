require_relative 'word_2_vec.rb'

puts "Starting to train"
word2vec = Word2Vec.new('investopedia_clean.txt')

word2vec.train
puts "Successfully trained vector"
