# Basis is a bunch of matrix cells
# with corresponding values
#
# @example
#
# b = TransportProblem::Basis.new({})
# => {}
# b[[1, 2]] = 3
# b[[5, 7]] = 5
# b
# => {[1, 2]=>3, [5, 7]=>5}
# c = Matrices::Cell.new([5,7])
# b[c] = 4
# b
# => {[1, 2]=>3, [5, 7]=>4}
#
class TransportProblem::Basis < DelegateClass(Hash)

  def initialize(h = {})
    super
  end

end