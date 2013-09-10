# class Float
#   COMPARISON_PRECISION = 1.0/10**2

#   def lt?(other)
#     self - other < COMPARISON_PRECISION
#   end

#   def gt?(other)
#     self - other > -COMPARISON_PRECISION
#   end

#   def eq?(other)
#     (self - other).abs <= COMPARISON_PRECISION
#   end

#   def <=>(other)
#     return 0 if eq?(other)
#     return -1 if lt?(other)
#     return 1 if gt?(other)
#   end

#   def ==(other)
#     (self <=> other) == 0
#   end
# end
