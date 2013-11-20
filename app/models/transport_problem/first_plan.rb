class TransportProblem::FirstPlan
  attr_accessor :data

  # @param data [TransportProblem::Data]
  # @param options [Hash] :method => :min | :corner
  #
  def self.for(data, options)
    method = options[:method] || :min

    case method
    when :min
      min_item_method(data)
    when :corner
      raise NotImplementedError
    else
      raise ArgumentError, "Unknown first plan method #{method}"
    end
  end

  def self.basis_size(data)
    data.m + data.n - 1
  end

  def self.min_item_method(d)
    # result = Array.new(basis_size, 0)
    data = d.clone
    result = Basis.new

    cell = data.min_c_cell
    a, b = data.a_b_for_min_c
    if a < b
      result[cell] = a
      data.delete_row!(cell.row)
      data.b[cell.column] -= a
    else
      result[cell] = b
      data.delete_column!(cell.column)
      data.a[cell.row] -= b
    end
  end
end
