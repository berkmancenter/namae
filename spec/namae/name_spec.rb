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
    
  end
end