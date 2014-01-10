module Parser
  class FunctionNode
    attr_accessor :children, :function


    def initialize(function = nil, children = [])
      @children = children
      @function = function
    end

    def permutation
      FunctionNodeEnumerator.new(self)
    end
    
    def to_s
      "#{@function.to_s}(#{@children.map { |x| x.to_s }.join(',')})"
    end

    def to_readable
      "(#{@children.map { |x| x.to_readable }.join(@function.to_s)})"
    end

    def all_functions
      functions = [@function]
      children.each do |child|
        if child.is_a? FunctionNode
          functions += child.all_functions
        end
      end
      functions
    end

    def functions_count
      functions = {@function => 1}
      children.each do |child|
        if child.is_a? FunctionNode
          child.functions_count.each do |function|
            functions[function] ||= 0
            functions[function] += 1
          end
        end
      end
      functions
    end

    def is_function?
      true
    end
    def is_element?
      false
    end
  end
end