# require 'gsl'

class Matrix < ActiveRecord::Base
  attr_accessor :gsl_matrix

  include Matrices::Optimization

  # args is array list
  def initialize(*args)
    @gsl_matrix = GSL::Matrix[*args]
  end

  # TODO: more effecient implementation
  def method_missing(method, *args)
    return @gsl_matrix.send(method, *args) if @gsl_matrix.respond_to?(method)
    super
  end

  def self.method_missing(method, *args)
    return GSL::Matrix.send(method, *args) if GSL::Matrix.respond_to?(method)
    super
  end

  def respond_to_missing?(method_name, include_private = false)
    @gsl_matrix.respond_to?(method_name) || super
  end

  def self.respond_to_missing?(method_name, include_private = false)
    GSL::Matrix.respond_to?(method_name) || super
  end

  # TODO: remove to_a because of precision
  def to_s
    to_a.to_s
  end

  alias :parsed :to_s

  def from_s(string)
    JSON.parse(string)
  end
end
