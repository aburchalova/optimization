module Statuses
  module Base
    extend ActiveSupport::Concern

    attr_accessor :code, :description, :data

    def initialize(hash = nil)
      return from_code!(self.class.initial_status.code) if !hash
      @code, @description, @data = hash.values_at(:code, :description, :data)
    end

    def finished?
      self.class.finish_statuses.has_key?(code)
    end

    def from_code!(code)
      @code = code
      @description = self.class.human_description(code)
      @data = nil
      self
    end

    def to_s
      description
    end

    module ClassMethods
      attr_accessor :statuses, :finish_statuses, :initial_status

      def set_statuses(hash)
        @statuses = hash
        define_helper_methods
      end

      def set_finish_statuses(*list)
        @finish_statuses = @statuses.slice(*list)
      end

      def set_initial_status(code)
        @initial_status = from_code(code)
      end

      # @param code [Symbol] snake case code
      #
      def from_code(code)
        new(:code => code, :description => human_description(code))
      end

      alias :[] :from_code

      def exists?(code)
        statuses.has_key?(code.to_sym)
      end

      def human_description(code)
        exists?(code) ? statuses[code] : code.to_s.humanize
      end

      # declare question methods for each status and
      # bang methods that set sufficient status
      #
      def define_helper_methods
        statuses.each_key do |key|
          define_method("#{key}?") { self.code == key }
          define_method("#{key}!") { from_code!(key) }
        end
      end
    end

  end
end
