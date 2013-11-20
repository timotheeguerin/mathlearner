module Parser
  class Tree
    attr_accessor :root, :cursor

    def initialize(text = nil)
      @text = text
      @root = nil
      @cursor = 0
    end

    def parse()
      next_node(0)
      @root
    end

    def next_node(priority)
      element = next_element
      operator = next_element
      if operator.nil?
        node = {:node => element}
        @root = node if @root.nil?
        node
      else
        node = FunctionNode.new
        @root = node if @root.nil?
        if operator.priority >= priority
          node.children << element
          node.function = operator
          next_node = next_node(operator.priority)
          node.children << next_node[:node]
          {:node => node}
        else
          node.children << @root
          node.function = operator
          next_node = next_node(operator.priority)
          node.children << next_node[:node]
          @root = node
          {:node => element, :root => node}
        end

      end
    end

    #Return a node or an operator
    def next_element
      ignore_whitespace
      string = @text[@cursor..-1]
      return nil if string.empty?
      #If we have a left parenthese then we create an other tree with the content of the parenthese
      if string[0] == '('
        sub_tree = Tree.new(string[1..-1])
        sub_tree.parse
        @cursor += sub_tree.cursor
        return sub_tree.root
      end
      #if we have a closing parentheses it's the end of the word(it's been preporcess before so this imply we have
      # recusively made a new tree with the inside of the parentheses)
      if string[0] == ')'
        @cursor += 1
        return nil
      end
      operator = get_operator(string)
      unless operator.nil?
        @cursor += 1
        return operator
      end
      index = 0
      until index >= string.length or string[index] == ')' or string[index].match(Regex::operator)
        index += 1
      end
      @cursor += index

      key = string[0...index]
      function = get_function(key)
      unless function.nil?
        node = FunctionNode.new(function)
        return node
      end

      element = get_element(string)
      unless element.nil?
        node = ElementNode.new(element, key)
        return node
      end
      throw ArgumentError, "Unkown element: #{key}"
    end

    def get_operator(string)
      Operator.all.each do |operator|
        return operator if string.match(Regexp.new("^#{operator.pattern}"))
      end
      nil
    end

    def get_function(string)
      Function.all.each do |function|
        return function if string.match(Regexp.new(function.pattern))
      end
      nil
    end

    def get_element(string)
      Element.all.each do |element|
        return element if string.match(Regexp.new "^#{element.pattern}")
      end
    end

    def ignore_whitespace
      while @text[@cursor] == ' '
        @cursor +=1
      end
    end
  end

  class Regex
    def self.operator
      Regexp.new(Operator.all.map { |x| x.pattern }.join('|'))
    end
  end
end