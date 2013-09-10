class MatrixInverter < Struct.new(:matrix, :k, :taken_column, :c, :c_inv, :available_column_indices, :status)

  # STATUSES = %w(initialized, step_completed, zero_alpha)
  STATUSES = {
    :initialized => 'initialized',
    :step_completed => 'step_completed',
    :zero_alpha => 'zero_alpha',
    :singular => 'matrix is singular'
  }

  # Only matrix should be passed
  #
  def initialize(*args)
    super
    @k = 0
    @taken_column = 0
    @c = Matrix.eye(matrix.size1)
    @c_inv = @c.clone
    @available_column_indices = 0...matrix.size1.to_a #not including size1
    @status = STATUSES[:initialized]
  end

  def run
    # @available_column_indices.each do |i|
    #   @k = i
    #   step
    # end
  end

  def step
    @c.set_col(@k, matrix.column(@taken_column)) #one step closer to initial matrix
    handle_inversing
    self
  end

  def handle_inversing
    begin
      @c_inv = Matrix.from_gsl(@c).inverse(@c_inv, @k)
      handle_successful_step_end
    rescue
      handle_singular_result
    end
  end

  def handle_singular_result
    take_next_column
    @status = @taken_column ? STATUSES[:zero_alpha] : STATUSES[:singular]
  end

  def take_next_column
    @taken_column = @available_column_indices.find { |col| col > @taken_column }
  end

  def handle_successful_step_end
    @status = STATUSES[:step_completed]
    pop_taken_column
    @k += 1
  end

  def pop_taken_column
    @available_column_indices.delete(@taken_column)
  end

  def surely_singular?

  end
end
