class RLex
  class SubLexer
    class << self
      def create
        Class.new(self){ @matchers = [] }
      end

      def define(&block)
        class_eval(&block)
        nil
      end

      def on(*patterns, &block)
        add_matcher patterns, block
      end

      def on_default(&block)
      end

      def dispose(*patterns)
      end

      def map
      end

      private

      def add_matcher(patterns, block)
        @matchers << Matcher.new(patterns, block)
      end
    end
  end
end

