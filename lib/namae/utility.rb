module Namae
  
  [:parse, :parse!].each do |method_id|
    define_method(method_id) do |*arguments|
      Parser.instance.send(method_id, *arguments)
    end
    
    module_function method_id
  end
    
  def options
    Parser.instance.options
  end
  
  module_function :parse, :parse!, :options
  
end