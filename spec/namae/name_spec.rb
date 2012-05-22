module Namae
  describe 'Name' do
    
    describe '.new' do
      
      it 'returns an empty name by default' do
        Name.new.should be_empty
      end
      
      it 'sets all passed-in attributes' do
        Name.new(:given => 'Foo').given.should == 'Foo'
      end

      it 'ignores unknown attributes' do
        Name.new(:foo => 'bar').should be_empty
      end
      
    end
    
    describe '#values_at' do
      it 'returns an array with the given values' do
        Name.new(:family => 'foo').values_at(:family).should == ['foo']
      end

      it 'returns an array with the given values' do
        Name.new(:family => 'foo').values_at(:family).should == ['foo']
      end
      
    end
    
    describe '#inspect' do
      it 'returns the name as a string' do
        Name.new(:given => 'Ichiro').inspect.should == '#<Name given="Ichiro">'
      end
    end
    
  end
end