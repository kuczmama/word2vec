class Vector
    attr_accessor :data
  
    def initialize(size, data = nil)
      @data = data || Array.new(size) { rand - 0.5 }
    end
  
    # Helper method to perform operation with error checking
    def perform_operation(other, operation)
      case other
      when Vector
        raise ArgumentError, "Vectors must have the same length" unless @data.length == other.data.length
        @data.zip(other.data).map { |x, y| x.send(operation, y) }
      when Numeric
        @data.map { |x| x.send(operation, other) }
      else
        raise TypeError, "Operation #{operation} is only supported for Vector and Numeric types"
      end
    end

    def cosine_similarity(other)
        dot(other) / (norm * other.norm)
    end

    def dot(other)
        raise "Must be a Vector to do a dot product" unless other.is_a?(Vector)
        raise "Vectors must have the same length" unless @data.length == other.data.length

        other.data.zip(@data).map { |x, y| x * y }.reduce(:+)
    end

    def norm()
        Math.sqrt(@data.map { |x| x**2 }.reduce(:+))
    end
  
    def +(other)
      Vector.new(@data.length, perform_operation(other, :+))
    end
  
    def -(other)
      Vector.new(@data.length, perform_operation(other, :-))
    end
  
    def *(other)
      Vector.new(@data.length, perform_operation(other, :*))
    end
  
    def /(other)
      Vector.new(@data.length, perform_operation(other, :/))
    end

    def [](index)
        @data[index]
    end

    def []=(index, value)
        @data[index] = value
    end
end
