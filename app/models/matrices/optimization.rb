module Matrices::Optimization
  extend ActiveSupport::Concern

  # Calculates alpha
  # If alpha is zero, the matrix is singular
  #
  # There is matrix [A] that's different from current matrix by +k+-th column, inversible (non-singular).
  # @param inverse [Matrix] Inverse to A
  # @param k [Fixnum] Number of column
  #
  # @return [Float]
  #
  def alpha(inverse, k)
    raise ArgumentError, 'Matrix is not square' if size1 != size2
    # as vect * matrix = matrix.transpose * vect
    inverse.transpose * self.class.eye_row(:size => size1, :index => k) * column(k)
  end

  # @see #alpha
  # 
  def singular?(inverse, k)
    alpha(inverse, k) == 0
  end

  # @see #alpha
  # 
  def inverse(inverse, k)
    a = alpha(inverse, k)
    raise ArgumentError, 'Matrix is not inversible' if a.zero?
    d = Matrix.eye(size1) # size1?
    z = - (inverse * column(k)).set(k, -1) / a
    d.set_col(k, z)
    d * inverse
  end

  module ClassMethods

    # Column with all zeros except one on +index+ place. Size +size+
    #
    # @param options [Hash]
    # @option options [Fixnum] :size
    # @option options [Fixnum] :index Zero-based
    #
    def eye_column(options)
      size = options[:size] || options[:index] + 1
      Matrix.eye(size).column(options[:index])
    end

    # @see .eye_column
    # 
    def eye_row(options)
      size = options[:size] || options[:index] + 1
      Matrix.eye(size).row(options[:index])
    end
  end
end
