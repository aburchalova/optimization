class TransportProblem::FirstPlan
  attr_accessor :initial_data, :result, :data

  def initialize(data)
    @initial_data = data
    @data = @initial_data.clone
    @result = Basis.new
  end

  def desired_basis_size
    data.m + data.n - 1
  end

  def basis_size
    result.size
  end

  # @param data [TransportProblem::Data]
  # @param options [Hash] :method => :min | :corner
  #
  def self.for(data, options)
    method = options[:method] || :corner

    case method
    when :min
      TransportProblem::MinItemMethod.new(data).find
    when :corner
      raise NotImplementedError
    else
      raise ArgumentError, "Unknown first plan method #{method}"
    end
  end
end
