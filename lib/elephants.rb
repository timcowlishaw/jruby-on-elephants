require 'java'
require 'csv'
require 'elephants/logistic_regression_classifier'
require 'elephants/text_analyzer'

import org.apache.lucene.analysis.standard.StandardFilter
import org.apache.lucene.analysis.standard.StandardAnalyzer
import org.apache.lucene.analysis.LowerCaseFilter
import org.apache.lucene.analysis.StopFilter
import org.apache.lucene.analysis.PorterStemFilter
import org.apache.lucene.util.Version

module Elephants

  DATA_FILE = File.join(File.dirname(__FILE__), "..", "data", "tweets.csv")


  class << self

   
    def strip_urls(string)
      string.gsub(/http:\/\/\S*/, "")
    end

    def strip_usernames(string)
      string.gsub(/@\w+/, "")
    end

    def strip_hashtags(string)
      string.gsub("#\w+", "")
    end

   
    def run
      data = CSV.read(DATA_FILE).shuffle
      training_data = data[0..data.length/2]
      testing_data = data[data.length/2..data.length-1]

      analyzer = TextAnalyzer.new(Version::LUCENE_34) do |a| 
        a.pre_processor do |text|
          strip_usernames(strip_hashtags(strip_urls(text)))
        end

        a.filter StandardFilter
        a.filter LowerCaseFilter
        a.filter(StopFilter) {|token_stream| [a.version, token_stream, StandardAnalyzer::STOP_WORDS_SET] }
        a.filter PorterStemFilter
      end

      classifier = LogisticRegressionClassifier.new(2, analyzer) do |classifier|
        training_data.each do |row|
          category = row[8].to_i
          text = row[7]
          classifier.train(category, text)
        end

        results = testing_data.map do |row|
          category = row[8].to_i
          text = row[7]
          [category] + classifier.test(category, text) + [text]
        end
        
        correct = results.select {|d| d[1]}
        incorrect = results - correct
        prop_correct = correct.length.to_f / results.length
        avg_log_likelihood = results.transpose[2].inject(&:+) / results.length

        sample_correct = correct.shuffle.take(10)
        sample_incorrect = incorrect.shuffle.take(10)

        puts "Example correct guesses:"
        puts sample_correct.map {|a| a.join(", ") }
        puts
        puts "Example incorrect guesses:"
        puts sample_incorrect.map {|a| a.join(", ") }
        puts
        puts "Proportion Correct: #{prop_correct}"
        puts "Average Log-Likelihood: #{avg_log_likelihood}"
      end
    end
  end
end
