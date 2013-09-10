module Matrices::Optimization
  extend ActiveSupport::Concern

  def invertible?

  end

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
    # as vect * matrix = matrix.transpose * vect
    inverse.transpose * self.class.eye_row(:size => size1, :index => k) * column(k)
  end

  # @see #alpha
  # 
  def singular?(inverse, k)
    alpha == 0
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
