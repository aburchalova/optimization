class Integer::TaskNode < Struct.new(:lower, :upper, :optimal_plan, :optimal_basis, :target_function)

  def initialize(*args)
    args[2] = args[2].map { |val| val.round(3) } if args[2]
    string_args = args.map &:to_s
    super(*string_args)
  end

  def to_h
    Hash[members.zip(values)].reject { |key, value| value.blank? }
  end

  def to_node_s
    members.zip(values).reject { |key, value| value.blank? }.join("\n")
  end


end