require 'java'

import java.io.StringReader
import org.apache.lucene.analysis.Analyzer
import org.apache.lucene.analysis.standard.StandardTokenizer
import org.apache.lucene.analysis.tokenattributes.TermAttribute
module Elephants
  class TextAnalyzer < Analyzer
    def initialize(version, &block)
      @version = version
      @filters = []
      @pre_processor = nil
      block.call(self)
      super()
    end

    attr_reader :version

    def filter(klass, &block)
      @filters << [klass, block]
    end

    def pre_processor(&block)
      @pre_processor = block
    end

    def each_token_for(string, &block)
      string = @pre_processor ? @pre_processor.call(string) : string
      string_reader = StringReader.new(string)
      tokens = token_stream(string_reader)
      term_attribute = tokens.add_attribute(TermAttribute.java_class)
      while(tokens.increment_token)
        block.call(term_attribute.term)
      end
    end

    def token_stream(reader)
      @filters.inject(StandardTokenizer.new(@version, reader)) do |chain, (filter, block)|
        filter.new *(block ? block.call(chain) : [chain])
      end
    end
  end
end
