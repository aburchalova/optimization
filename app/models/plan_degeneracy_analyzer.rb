# working_task_matrix a is matrix from artificial task (i.e. wide one), maybe with excluded rows
# jk is an artificial index in working basis
# basis is working basis
#
# Plan is degenerate : can go with multiple basises, if there is non-zero alpha for one
# of the real non-basis indices.
#
class PlanDegeneracyAnalyzer < Struct.new(:working_task_matrix, :basis, :real_indices, :jk)

  def initialize(hash)
    super(*hash.values_at(*self.class.members))
  end

  # Variable index from real ones (not artificial) aka j0
  # to which alpha[j0] != 0
  # This index can be added to basis.
  #
  def real_basis_candidate
    k = basis.index(jk)
    non_zero_alpha_index(k)
  end

  protected

  # Returns nil if all alphas are zero
  def non_zero_alpha_index(k)
    as = alphas(k)
    as.index(&:nonzero?)
  end

  # k is eye matrix column number that will be used for calculations
  #
  def alphas(k)
    result = Array.new(working_task_matrix.size2, 0) # ??? new width == working task matrix width?
    real_non_basis_indices.map do |j|
      result[j] = alpha(j, k)
    end
  end

  # aj = e'k * A_result_basis^(-1) * Aj
  # where A_result_basis is artificial result basis matrix
  # and Aj is initial, 'clean' task j-th column
  #
  # @param result_basis_matrix [Matrix] A_result_basis, basis matrix from previous step
  # initially it's equal to artificial task result basis matrix
  #
  def alpha(j, k)
    working_basis_matrix.invert.transpose *
      Matrix.eye_row(:size => working_basis_matrix.size1, :index => k) *
      working_task_matrix.column(k)
  end

  # working_basis is supposed to be real_task_basis
  # working_basis contains indices from 0 till n + m
  #
  def working_basis_matrix
    @working_basis_matrix ||= working_task_matrix.cut(basis)
  end

  # Initial task indices 0..n that are not in the artificial task result basis aka basis
  #
  def real_non_basis_indices
    @real_non_basis_indices ||= real_indices - basis
  end
end
