module NewTaskComposing
  extend ActiveSupport::Concern

  def compose_new_task
    return task if finished?
    inverted_new_matrix = new_a_b_inv
    task.with(new_x, new_basis).tap do |t|
      t.inverted_basis_matrix = inverted_new_matrix
    end
  end

  def new_x
    result = Array.new(task.n, 0)
    fill_basis_components(result)
    fill_non_basis_components(result)
    Matrix.new(result).transpose
  end

  def new_basis
    # puts "new basis: #{task.basis_indexes.dup.tap { |indices| indices[s] = new_basis_column }}"
    task.basis_indexes.dup.tap { |indices| indices[basis_col_to_remove] = new_basis_column }
  end

  # Index of minimal theta. New basis matrix will be different by column #s
  def basis_col_to_remove
    task.min_theta_index
  end
  alias :s :basis_col_to_remove

  def new_nonbasis_column
    task.basis_indexes[s]
  end

  def new_basis_column
    task.j0
  end

  def new_a_b
    # puts "old basis matrix: \n#{task.a_b}\nnew basis: #{new_basis}\nnew basis matrix: #{task.a.cut(new_basis)}"
    task.a.cut(new_basis)
  end

  def new_a_b_inv
    new_a_b.inverse(task.a_b_inv, s)
  end

  def fill_basis_components(result)
    # for each i in basis indexes newx[j_i] = x[j_i] - min_theta * z[i]
    task.z_ary.each_with_index do |zi, i|
      x_idx = task.basis_indexes[i]
      result[x_idx] = task.x_ary[x_idx] - task.min_theta * zi
    end
    result
  end

  def fill_non_basis_components(result)
    result[task.j0] = task.min_theta
    result
  end
end

