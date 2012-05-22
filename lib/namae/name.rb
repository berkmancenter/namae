module Namae
  
  # A Name represents a single personal name, exposing its constituent
  # parts (e.g., family name, given name etc.). Name instances are typically
  # created and returned from {Namae.parse Namae.parse}.
  #
  #     name = Namae.parse('Yukihiro "Matz" Matsumoto')[0]
  #     
  #     name.family #=> Matsumoto
  #     name.nick #=> Matz
  #     name.given #=> Yukihiro
  #
  class Name < Struct.new :family, :given, :suffix, :particle,
    :dropping_particle, :nick

    # @param attributes [Hash] the individual parts of the name
    # @example
    #   Name.new(:family => 'Matsumoto')
    def initialize(attributes = {})
      super(*attributes.values_at(*Name.members))
    end
  

    # Returns true if all the name components are nil.
    def empty?
      values.compact.empty?
    end

    
    # @overload values_at(selector, ... )
    #   Returns an array containing the elements in self corresponding to
    #   the given selector(s). The selectors may be either integer indices,
    #   ranges (functionality inherited from Struct) or symbols
    #   idenifying valid keys.
    #
    # @example
    #   name.values_at(:family, :nick) #=> ['Matsumoto', 'Matz']
    #
    # @see Struct#values_at
    # @return [Array] the list of values
    def values_at(*arguments)
      super(*arguments.flatten.map { |k| k.is_a?(Symbol) ? Name.members.index(k) : k})
    end
    
    
    # Describe the contents of this name in a string.
    def inspect
      "#<Name #{each_pair.map { |k,v| [k,v.inspect].join('=') if v }.compact.join(' ')}>"
    end
        
  end
end