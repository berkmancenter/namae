module Namae
  
  class Name < Struct.new :family, :given, :suffix, :particle,
    :dropping_particle, :nick
  
    def initialize(attributes = {})
      super(*attributes.values_at(*Name.members))
    end
  
    def empty?
      values.compact.empty?
    end
    
  end
end