class SimplexSolverStatus < Struct.new(:code, :description, :data)
  STATUSES = {
    :initialized => 'initialized',
    :optimal => 'optimal',
    :singular => 'matrix is singular',
    :unlimited => 'unlimited',
    :step_completed => 'step completed',
    :not_a_plan => 'given vector is not a plan'
  }

  FINISH_STATUSES = STATUSES.slice(:singular, :unlimited, :optimal, :not_a_plan)

  def initialize(hash)
    super(*hash.values_at(*self.class.members))
  end

  def finished?
    FINISH_STATUSES.has_key?(code)
  end

  def from_code!(code)
    self.code = code
    self.description = SimplexSolverStatus.human_description(code)
    self.data = nil
    self
  end

  class << self

    # @param code [Symbol] snake case code
    #
    def from_code(code)
      new(:code => code, :description => human_description(code))
    end

    alias :[] :from_code

    def exists?(code)
      STATUSES.has_key?(code.to_sym)
    end

    def human_description(code)
      exists?(code) ? STATUSES[code] : code.to_s.humanize
    end
  end

  # declare question methods for each status and
  # bang methods that set sufficient status
  #
  STATUSES.each_key do |key|
    define_method("#{key}?") { self.code == key }
    define_method("#{key}!") { from_code!(key) }
  end



end
