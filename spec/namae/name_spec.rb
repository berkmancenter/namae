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

    describe '.parse' do
      it 'returns an empty name for an empty string' do
        Name.parse('').should be_empty
        Name.parse('').should be_a(Name)
      end

      it 'returns a single name object if there is more than one name' do
        Name.parse('Plato and Sokrates').given.should == 'Plato'
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

    describe '#initials' do
      it "returns the name's initials" do
        Name.new(:family => 'Poe', :given => 'Edgar A.').initials.should == 'E.A.P.'
      end

      it "returns the name's initials but leaves the family name expanded" do
        Name.new(:family => 'Poe', :given => 'Edgar A.').initials(:expand => true).should == 'E.A. Poe'
      end
    end

    describe '#merge' do
      it 'merges the attributes in the given hash into the name' do
        Name.new.merge(:family => 'foo').family.should == 'foo'
      end

      it 'merges the attributes in the given name into the name' do
        Name.new.merge(Name.new(:family => 'foo')).family.should == 'foo'
      end

      it 'ignores unknown attributes' do
        Name.new.merge(:foo => 'bar').should be_empty
      end

      it 'ignores nil values' do
        Name.new(:family => 'foo').merge(:family => nil).family.should == 'foo'
      end
    end

    describe '#inspect' do
      it 'returns the name as a string' do
        Name.new(:given => 'Ichiro').inspect.should == '#<Name given="Ichiro">'
      end
    end

    describe '#sort_order' do
      it 'returns an empty string by default' do
        Name.new.sort_order.should == ''
      end

      it 'returns the name in sort order' do
        Name.new(:given => 'Ichiro', :family => 'Suzuki').sort_order.should == 'Suzuki, Ichiro'
      end

      it 'returns only the given if there is no family name' do
        Name.new(:given => 'Ichiro').sort_order.should == 'Ichiro'
      end

      it 'returns only the family if there is no given name' do
        Name.new(:family => 'Suzuki').sort_order.should == 'Suzuki'
      end

      it 'includes the suffix' do
        Name.new(:family => 'Griffey', :suffix => 'Jr.').sort_order.should == 'Griffey, Jr.'
        Name.new(:family => 'Griffey', :given => 'Ken', :suffix => 'Jr.').sort_order.should == 'Griffey, Jr., Ken'
      end
    end

    describe '#display_order' do
      it 'returns an empty string by default' do
        Name.new.display_order.should == ''
      end

      it 'returns the name in display order' do
        Name.new(:given => 'Ichiro', :family => 'Suzuki').display_order.should == 'Ichiro Suzuki'
      end

      it 'returns only the given if there is no family name' do
        Name.new(:given => 'Ichiro').display_order.should == 'Ichiro'
      end

      it 'returns only the family if there is no given name' do
        Name.new(:family => 'Suzuki').display_order.should == 'Suzuki'
      end

      it 'includes the suffix' do
        Name.new(:family => 'Griffey', :suffix => 'Jr.').display_order.should == 'Griffey Jr.'
        Name.new(:family => 'Griffey', :given => 'Ken', :suffix => 'Jr.').display_order.should == 'Ken Griffey Jr.'
      end
    end

  end
end
