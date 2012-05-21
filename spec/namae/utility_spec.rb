describe 'Namae' do

  describe '.parse' do
    it 'returns an empty list by default' do
      Namae.parse('').should be_empty
    end
  end

  describe '.parse!' do
    it 'returns an empty list by default' do
      Namae.parse!('').should be_empty
    end
  end
    
  describe '.options' do
    it 'returns the parse options' do
      Namae.options.should equal(Namae::Parser.instance.options)
    end
  end

end