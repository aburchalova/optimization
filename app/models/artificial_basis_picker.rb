# Analyzes if there are artificial variables in basis
# and gives them ^_^

class ArtificialBasisPicker < Struct.new(:basis, :artificial_indices)

  def initialize(hash)
    super(*hash.values_at(*self.class.members))
  end

  # We have artificial task result and its basis.
  # Its basis contains artificial variables.
  # Take first index from these basis artificial variables.
  #
  # Returns variable num #and its index in current basis.
  #
  # If no intersection, returns nil.
  #
  def take
    raise "ArtificialBasisPicker got nil as working basis" unless basis
    intersect.shift
  end

  def intersect
    @intersect ||= basis & artificial_indices
  end

  def no_artifitial_intersect?
    intersect.empty?
  end

end
