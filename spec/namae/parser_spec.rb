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
				before(:each) do
					Parser.instance.reset
				end

        describe 'when the input is empty' do
          it 'returns nil' do
            parser.send(:next_token).should be_nil
          end
        end

        describe 'when the next input is " and "' do
          before { parser.send(:input).string = ' and ' }
          it 'returns an AND token' do
            parser.send(:next_token).should == [:AND, :AND]
          end
        end

        describe 'when the next input is " & "' do
          before { parser.send(:input).string = ' & ' }
          it 'returns an AND token' do
            parser.send(:next_token).should == [:AND, :AND]
          end
        end

        describe 'when the next input is " , "' do
          before { parser.send(:input).string = ' , ' }
          it 'returns a COMMA token' do
            parser.send(:next_token).should == [:COMMA, :COMMA]
          end
        end

        describe 'when the next input is " \'foo bar\' "' do
          before { parser.send(:input).string = " 'foo bar' " }
          it 'returns a NICK token' do
            parser.send(:next_token).should == [:NICK, 'foo bar']
          end
        end

        %w{Mr. Mr Mrs. Ms Herr Frau Miss}.each do |appellation|
          describe "the next token is #{appellation.inspect}" do
            before { parser.send(:input).string = appellation }
            it 'returns an APPELLATION token' do
              parser.send(:next_token).should == [:APPELLATION, appellation]
            end
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

          it 'treats "Lord Byron" as a title and family name' do
            parser.parse!('Lord Byron')[0].values_at(:family, :title).should == ['Byron', 'Lord']
          end

          it 'parses given and family part name in "Ichiro Suzuki"' do
            parser.parse!('Ichiro Suzuki')[0].values_at(:given, :family).should == %w{Ichiro Suzuki}
          end

          it 'parses given, nick and family part name in "Yukihiro \'Matz\' Matsumoto"' do
            parser.parse!("Yukihiro 'Matz' Matsumoto")[0].values_at(:given, :family, :nick).should == %w{Yukihiro Matsumoto Matz}
          end

          it 'parses given, nick and family part name in \'Yukihiro "Matz" Matsumoto\'' do
            parser.parse!('Yukihiro "Matz" Matsumoto')[0].values_at(:given, :family, :nick).should == %w{Yukihiro Matsumoto Matz}
          end

          it 'parses given and family name in "Poe, Edgar A."' do
            parser.parse!('Poe, Edgar A.')[0].values_at(:given, :family).should == ['Edgar A.', 'Poe']
          end

          %w{Mr. Mr Mrs. Ms Herr Frau Miss}.each do |appellation|
            it "recognizes #{appellation.inspect} as an appellation" do
              parser.parse!([appellation, 'Edgar A. Poe'].join(' '))[0].appellation.should == appellation
            end
          end

        end
      end

    end
  end
end