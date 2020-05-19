class RLex
  Context = Struct.new(:state, :lineno, :column)

  class Context
    def exec(*args, &block)
      instance_exec(*args, &block)
    end
  end
end

