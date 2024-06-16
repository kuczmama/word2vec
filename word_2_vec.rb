require_relative 'vector.rb'

class Word2Vec
  attr_accessor :corpus, :vocab, :window_size, :vectors, :learning_rate, :epochs

  def initialize(
      corpus,
      window_size = 2,
      vector_size = 100,
      learning_rate = 0.025,
      epochs = 10)
    @corpus = corpus
    @window_size = 2
    @vector_size = vector_size
    @vocab = get_vocab(corpus)
    @vectors = create_vectors(@vocab, @vector_size)
    @learning_rate = learning_rate
    @epochs = epochs
  end

  def create_vectors(vocab, vector_size)
    vectors = {}
    vocab.each do |word|
      vectors[word] = Vector.new(vector_size)
    end
    vectors
  end

  def get_vocab(corpus)
    corpus.map(&:split).flatten.uniq
  end

  def train()
    @epochs.times do |epoch|
      @corpus.each do |sentence|
        words = sentence.split
        words.each_with_index do |word, i|
          next if @vectors[word].nil?
          start_context = [i - window_size, 0].max
          end_context = [i + window_size, words.length - 1].min
          (start_context..end_context).map do |j|
            next if i == j # don't train on the same word
            context_word = words[j]

            next if @vectors[context_word].nil? # don't train on missing words
            target_vector = @vectors[word]
            context_vector = @vectors[context_word]

            target_vector.each_with_index do |target, vector_idx|
              gradient = target - context_vector[vector_idx]
              context_vector[vector_idx] -= gradient * @learning_rate
              target_vector[vector_idx] -= gradient * @learning_rate
            end
          end
        end
      end
      puts "Epoch #{epoch}/#{@epochs}"
    end
  end

end