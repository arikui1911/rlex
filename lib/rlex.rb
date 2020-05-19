require 'rlex/token'
require 'rlex/context'
require 'rlex/sublexer'

class RLex
  def self.initial_state(name)
    @initial_state = name
  end

  def self.state(name, &block)
    (@sublexers[name] ||= SubLexer.create).define(&block)
  end

  def initialize(src)
    @src = src
    @eof = false
    @fib = Fiber.new(&method(:lex))
    @context = Context.new
    @initial = self.class.instance_variable_get(:@initial_state)
    @sublexer_classes = self.class.instance_variable_get(:@sublexers)
    @sublexers = Hash.new{|h, k| h[k] = @sublexer_classes.fetch(k).new }
  end

  def read
    @eof ? nil : @fib.resume
  end

  private

  def lex
    @context.state = @initial
    @context.lineno = 1
    @context.column = 1
    @src.each_line do |line|
      rest = line
      until rest.empty?
        rest = @sublexers[@context.state].lex(@context, rest)
        @context.column = line.size - rest.size + 1
      end
      @context.lineno += 1
      @context.column = 1
    end
    @eof = true
    Token.new(:EOF, nil, @context.lineno, @context.column)
  end
end

