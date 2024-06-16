require 'json'
require 'set'
require_relative 'vector.rb'
require 'byebug'

class Word2Vec
  attr_accessor :corpus_path, :vocab, :window_size, :vectors, :learning_rate, :epochs

  def initialize(
      corpus_path,
      window_size = 2,
      vector_size = 100,
      learning_rate = 0.025,
      epochs = 10)
    @corpus_path = corpus_path
    @window_size = window_size
    @vector_size = vector_size
    @learning_rate = learning_rate
    @epochs = epochs
    @vocab = build_vocab
    @vectors = load_vectors || create_vectors
  end

  def build_vocab
    vocab = Set.new
    File.foreach(@corpus_path) do |line|
      words = line.split
      words.each { |word| vocab.add(word) }
    end
    vocab
  end


  def create_vectors
    vectors = {}
    @vocab.each do |word|
      vectors[word] = Vector.new(@vector_size)
    end
    vectors
  end

  def save_vectors
    puts "Saving vectors: "
    if @vectors.empty?
      puts "Warning: Attempting to save an empty vector set."
    else
      File.write('vectors.json', @vectors.transform_values { |vec| vec.data }.to_json, mode: 'w')
    end
    puts "Vector saved"
  end
  

  def load_vectors
    return unless File.exist?('vectors.json')
    data = File.read('vectors.json')
    return nil if data.nil? || data.strip.empty?
    JSON.parse(data).transform_values { |data| Vector.new(data.length, data) }
  end

  def train()
    start_epoch = load_epoch_progress || 0
    (start_epoch...@epochs).each do |epoch|
      File.foreach(@corpus_path).with_index do |line, line_number|
        next if line_number < load_sentence_progress
        words = line.split
        words.each_with_index do |word, i|
          next if @vectors[word].nil?
          start_context = [i - @window_size, 0].max
          end_context = [i + @window_size, words.length - 1].min
          (start_context..end_context).each do |j|
            next if i == j || @vectors[words[j]].nil?
            update_vectors(word, words[j])
          end
        end
        save_sentence_progress(line_number)
        save_epoch_progress(epoch)
        save_vectors
      end
      puts "Epoch #{epoch + 1}/#{@epochs} completed."
    end
      cleanup_progress_files
  end
  
  private

  def update_vectors(target, context)
    target_vector = @vectors[target]
    context_vector = @vectors[context]
  
    target_vector.data.each_with_index do |value, idx|
      gradient = value - context_vector[idx]
      target_vector[idx] -= @learning_rate * gradient
      context_vector[idx] -= @learning_rate * gradient
    end
  end
  

  def save_epoch_progress(epoch)
    File.write('epoch_progress.txt', epoch.to_s)
  end

  def load_epoch_progress
    File.exist?('epoch_progress.txt') ? File.read('epoch_progress.txt').to_i : 0
  end

  def save_sentence_progress(index)
    File.write('sentence_progress.txt', index.to_s)
  end

  def load_sentence_progress
    File.exist?('sentence_progress.txt') ? File.read('sentence_progress.txt').to_i : 0
  end  

  def cleanup_progress_files
    File.delete('epoch_progress.txt') if File.exist?('epoch_progress.txt')
    File.delete('sentence_progress.txt') if File.exist?('sentence_progress.txt')
  end
end
