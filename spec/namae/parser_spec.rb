module Namae
  describe 'Parser' do
    
    it 'does not respond to .new' do
      Parser.should_not respond_to(:new)
    end
    
    describe '.instance' do
      let(:parser) { Parser.instance }
      
      it 'returns the parser' do
        parser.should be_a(Parser)
      end
      
      describe '#next_token' do
        describe 'when the input is empty' do
          it 'returns nil' do
            parser.send(:next_token).should be_nil
          end
        end
        
        describe 'when the next input is " and "' do
          before { parser.send(:input).string = ' and ' }
          it 'returns an AND token' do
            parser.send(:next_token).should == [:AND, nil]
          end
        end

        describe 'when the next input is " , "' do
          before { parser.send(:input).string = ' , ' }
          it 'returns a COMMA token' do
            parser.send(:next_token).should == [:COMMA, nil]
          end
        end
      end
      
      describe '#parse!' do
        it 'returns an empty list by default' do
          parser.parse!('').should be_empty
        end
        
        it 'returns a list of names' do
          parser.parse!('foo')[0].should be_a(Name)
        end
        
        describe 'when parsing a single name' do
          
          it 'treats "Ichiro" as a given name' do
            parser.parse!('Ichiro')[0].given.should == 'Ichiro'
          end
          
          it 'parses given and family part name in "Ichiro Suzuki"' do
            parser.parse!('Ichiro Suzuki')[0].values_at(:given, :family).should == %w{Ichiro Suzuki}
          end
        end
      end
      
    end  
  end
end