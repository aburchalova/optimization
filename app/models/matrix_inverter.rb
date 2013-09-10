class MatrixInverter < Struct.new(:matrix, :k, :taken_column, :c, :c_inv,
  :available_column_indices, :status, :show_log, :result, :actual_column_sequence)

  # STATUSES = %w(initialized, step_completed, zero_alpha)
  STATUSES = {
    :initialized => 'initialized',
    :step_completed => 'step_completed',
    :zero_alpha => 'zero_alpha',
    :singular => 'matrix is singular',
    :success => 'matrix inverted'
  }

  END_STATUSES = STATUSES.slice(:success, :singular)

  # Only matrix should be passed
  #
  def initialize(*args)
    super
    init(args.first)
  end

  def reinit
    init(matrix)
  end

  def init(matrix)
    self.k = 0
    self.taken_column = 0
    self.c = Matrix.eye(matrix.size1)
    self.c_inv = c.clone
    self.available_column_indices = (0...matrix.size1).to_a #not including size1
    self.status = STATUSES[:initialized]
    self.actual_column_sequence = []
    self
  end
  protected :init

  def enable_log!
    self.show_log = true
  end

  def run
    step until finished?
    replace_rows if !singular?
  end

  def step
    return self if finished?
    self.c.set_col(k, matrix.column(taken_column)) #one step closer to initial matrix
    handle_inversing
    self
  end

  def handle_inversing
    begin
      self.c_inv = Matrix.from_gsl(c).inverse(c_inv, k)
      handle_successful_step_end
    rescue
      handle_singular_result
    end
    puts to_s if show_log
  end

  def handle_singular_result
    take_next_column
    self.status = taken_column ? STATUSES[:zero_alpha] : STATUSES[:singular]
  end

  def take_next_column
    self.taken_column = available_column_indices.find { |col| col > taken_column }
  end

  def take_first_available_column
    self.taken_column = available_column_indices.first
  end

  def handle_successful_step_end
    store_taken_column
    take_first_available_column
    self.k += 1
    self.status = taken_column ? STATUSES[:step_completed] : STATUSES[:success]
  end

  def store_taken_column
    self.available_column_indices.delete(taken_column)
    actual_column_sequence << taken_column
  end

  # Checks if the result multiplied by initial matrix gives identity matrix
  # Warning: inverts original matrix
  #
  def check
    result == expected
  end

  def expected
    begin
      @expected ||= matrix.invert
    rescue GSL::ERROR::EDOM
    end
  end

  def finished?
    END_STATUSES.values.include?(status)
  end

  def singular?
    status == STATUSES[:singular]
  end

  def replace_rows
    rows = c_inv.to_a
    sorted = rows.sort_by { |row| actual_column_sequence[rows.index(row)]  }
    self.result = Matrix.new(*sorted)
  end

  def to_s
    %Q(
--------MATRIX INVERTER-----STATUS: #{status}---------
  Initial matrix:
  #{matrix.to_s}

  Working matrix copy (aka C):
  #{c.to_s}

  Inverted working matrix (aka B):
  #{c_inv.to_s}

  Will try to insert into:
  #{k}

  Will try to insert initial column #:
  #{taken_column}

  Unused columns:
  #{available_column_indices.join(', ')}

  Actual column indices sequence:
  #{actual_column_sequence.join(', ')}
------------------------------------------------------
    )
  end
end
