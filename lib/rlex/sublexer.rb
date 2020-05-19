require 'rlex/matcher'

class RLex
  module NormalizableAsPattern
    refine String do
      def normalize_as_rlex_pattern
        /\A#{Regexp.quote self}/
      end
    end

    refine Regexp do
      def normalize_as_rlex_pattern
        return self if source.start_with?('\\A')
        /\A#{self}/
      end
    end
  end

  class SubLexer
    def initialize
      @matchers = self.class.instance_variable_get(:@matchers)
    end

    def lex(context, src)
      @matchers.each do |matcher|
        m = matcher.match(src) or next
        context.exec(m[0], &matcher.block) if matcher.block
        return m.post_match
      end
      raise 'no matched pattern'
    end

    using NormalizableAsPattern

    class << self
      def create
        Class.new(self){ @matchers = [] }
      end

      def define(&block)
        class_eval(&block)
        nil
      end

      def on(*patterns, &block)
        raise ArgumentError, 'no block given' unless block_given?
        add_matcher(*patterns.map(&:normalize_as_rlex_pattern), &block)
      end

      def on_default(&block)
        add_matcher(/\A./, /\A\n/, &block)
      end

      def dispose(*patterns)
        add_matcher(*patterns.map(&:normalize_as_rlex_pattern))
      end

      def map(*args, &block)
        if block_given?
          map_table(args.to_h{|x| [x, yield(x)] }, &block)
        else
          map_table(*args)
        end
      end

      private

      def map_table(raw_table)
        table = Hash.try_convert(table)
        raise ArgumentError, "#{raw_table.inspect}(#{raw_table.class}) is not compatible to Hash" unless table
        add_matcher(/\A#{Regexp.union(*table.keys.sort_by(&:size).reverse)}/) do |m|
          emit table.fetch(m), m
        end
      end

      def add_matcher(*patterns, &block)
        @matchers << Matcher.new(*patterns, &block)
      end
    end
  end

  class Matcher
    def initialize(*patterns, &block)
      @patterns = patterns
      @block = block
    end

    attr_reader :block

    def match(src)
      @patterns.each do |pattern|
        m = pattern.match(src) or return m
      end
      nil
    end
  end
end

