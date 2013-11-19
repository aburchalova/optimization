# Cell chain is an array of matrix cells
# where every two neighbour cells
# share a row or a column, but
# no row or column has 3 cells in it.
#
class Matrices::CellChain

  # @param ary [Array<Array<Fixnum>]
  # 
  # @example
  #
  # Matrices.CellChain.from([1, 2], [2, 3])
  #
  def self.from(ary)

  end

  # If given array of cells is a chain, composes it,
  # else returns nil
  #
  def self.is_chain?(ary)
    # need to remove last cell
    ary.each_with_index do |cell, idx|

    end
  end

  def cycle?

  end
end
