require 'java'


import org.apache.mahout.vectorizer.encoders.AdaptiveWordValueEncoder
import org.apache.mahout.vectorizer.encoders.ConstantValueEncoder
import org.apache.mahout.classifier.sgd.OnlineLogisticRegression
import org.apache.mahout.classifier.sgd.L1
import org.apache.mahout.math.DenseVector
import org.apache.mahout.math.RandomAccessSparseVector

module Elephants
  class LogisticRegressionClassifier

    DEFAULT_PARAMS = {
      :alpha => 1,
      :step_offset => 1000,
      :decay_exponent => 0.9,
      :lambda => 3.0e-5,
      :learning_rate => 20,
      :features => 100000,
      :prior => L1.new
    }

    def initialize(classes, analyzer, params={}, &block)
      @params = DEFAULT_PARAMS.merge(params)
      @classes = classes
      @analyzer = analyzer
      @text_encoder = AdaptiveWordValueEncoder.new("text")
      @algo = OnlineLogisticRegression.new(@classes, @params[:features], @params[:prior]).alpha(@params[:alpha]).step_offset(@params[:step_offset]).decay_exponent(@params[:decay_exponent]).lambda(@params[:lambda]).learning_rate(@params[:learning_rate])
      if block
        block.call(self)
        finalise
      end
    end

    def train(category, example)
      vector = vector_for(example)
      @algo.train(category, vector)
    end

    def classify(example)
      vector = example.is_a?(RandomAccessSparseVector) ? example : vector_for(example) 
      result_vector = DenseVector.new(@classes)
      @algo.classify_full(result_vector, vector)
      return result_vector.max_value_index
    end

    def test(category, example)
      vector = vector_for(example)
      result = classify(vector)
      correct = category == result
      ll = @algo.log_likelihood(category, vector)
      return [correct, ll]
    end

    def finalise
      @algo.close
    end

    private
    

    def vector_for(example)
      vector = RandomAccessSparseVector.new(@params[:features])
      @analyzer.each_token_for(example) do |token|
        @text_encoder.add_to_vector(token, vector)
      end
      return vector
    end
  end
end
