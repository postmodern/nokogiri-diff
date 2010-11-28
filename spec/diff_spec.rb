require 'spec_helper'
require 'nokogiri/diff'

describe "nokogiri/diff" do
  let(:contents) { '<div><p>one</p></div>' }
  let(:doc) { Nokogiri::XML(contents) }

  let(:added_text) { Nokogiri::XML('<div><p>one</p>two</div>') }
  let(:added_element) { Nokogiri::XML('<div><p>one</p><p>two</p></div>') }
  let(:added_attr) { Nokogiri::XML('<div><p id="1">one</p></div>') }

  let(:changed_text) { Nokogiri::XML('<div><p>two</p></div>') }
  let(:changed_element) { Nokogiri::XML('<div><span>one</span></div>') }
  let(:changed_attr_name) { Nokogiri::XML('<div><p i="1">one</p></div>') }
  let(:changed_attr_value) { Nokogiri::XML('<div><p id="2">one</p></div>') }

  let(:removed_text) { Nokogiri::XML('<div><p></p>two</div>') }
  let(:removed_element) { Nokogiri::XML('<div></div>') }
  let(:removed_attr) { Nokogiri::XML('<div><p>one</p></div>') }

  it "should add #diff to Nokogiri::XML::Docuemnt" do
    doc.should respond_to(:diff)
  end

  it "should add #diff to Nokogiri::XML::Element" do
    added_element.at('div').should respond_to(:diff)
  end

  it "should add #diff to Nokogiri::XML::Text" do
    added_text.at('p/text()').should respond_to(:diff)
  end

  it "should add #diff to Nokogiri::XML::Attr" do
    added_attr.at('p/@id').should respond_to(:diff)
  end

  it "should determine when two different documents are identical" do
    doc.diff(Nokogiri::XML(contents)).all? { |change,node|
      change == ' '
    }.should == true
  end

  it "should search down within Nokogiri::XML::Document objects" do
    doc.diff(changed_text).any? { |change,node|
      change != ' '
    }.should == true
  end

  it "should determine when text nodes are added" do
    changes = doc.at('div').diff(added_text.at('div')).to_a

    changes.length.should == 3

    changes[0][0].should == ' '
    changes[0][1].should == doc.at('//p')

    changes[1][0].should == '+'
    changes[1][1].should == added_text.at('//div/text()')

    changes[2][0].should == ' '
    changes[2][1].should == doc.at('//p/text()')
  end

  it "should determine when elements are added" do
    changes = doc.at('div').diff(added_element.at('div')).to_a

    changes.length.should == 4

    changes[0][0].should == '+'
    changes[0][1].should == added_element.at('//p[1]')

    changes[1][0].should == ' '
    changes[1][1].should == doc.at('//p')

    changes[2][0].should == '-'
    changes[2][1].should == doc.at('//p/text()')

    changes[3][0].should == '+'
    changes[3][1].should == added_element.at('//p[2]/text()')
  end

  it "should determine when attributes are added" do
    changes = doc.at('p').diff(added_attr.at('p')).to_a

    changes.length.should == 2

    changes[0][0].should == '+'
    changes[0][1].should == added_attr.at('//p/@id')

    changes[1][0].should == ' '
    changes[1][1].should == doc.at('//p/text()')
  end

  it "should determine when text nodes differ" do
    changes = doc.at('p').diff(changed_text.at('p')).to_a

    changes.length.should == 2

    changes[0][0].should == '-'
    changes[0][1].should == doc.at('//p/text()')

    changes[1][0].should == '+'
    changes[1][1].should == changed_text.at('//p/text()')
  end

  it "should determine when element names differ" do
    changes = doc.at('div').diff(changed_element.at('div')).to_a

    changes.length.should == 2

    changes[0][0].should == '-'
    changes[0][1].should == doc.at('p')

    changes[1][0].should == '+'
    changes[1][1].should == changed_element.at('span')
  end

  it "should determine when attribute names differ" do
    changes = added_attr.at('p').diff(changed_attr_name.at('p')).to_a

    changes.length.should == 3

    changes[0][0].should == '-'
    changes[0][1].should == added_attr.at('//p/@id')

    changes[1][0].should == '+'
    changes[1][1].should == changed_attr_name.at('//p/@i')

    changes[2][0].should == ' '
    changes[2][1].should == added_attr.at('//p/text()')
  end

  it "should determine when attribute values differ" do
    changes = added_attr.at('p').diff(changed_attr_value.at('p')).to_a

    changes.length.should == 3

    changes[0][0].should == '-'
    changes[0][1].should == added_attr.at('//p/@id')

    changes[1][0].should == '+'
    changes[1][1].should == changed_attr_value.at('//p/@id')

    changes[2][0].should == ' '
    changes[2][1].should == added_attr.at('//p/text()')
  end

  it "should determine when text nodes are removed" do
    changes = added_text.at('div').diff(removed_text.at('div')).to_a

    changes.length.should == 3

    changes[0][0].should == ' '
    changes[0][1].should == added_text.at('p')

    changes[1][0].should == ' '
    changes[1][1].should == added_text.at('//div/text()')

    changes[2][0].should == '-'
    changes[2][1].should == added_text.at('//p/text()')
  end

  it "should determine when elements are removed" do
    changes = added_element.at('div').diff(removed_element.at('div')).to_a

    changes.length.should == 2

    changes[0][0].should == '-'
    changes[0][1].should == added_element.at('//p[1]')

    changes[1][0].should == '-'
    changes[1][1].should == added_element.at('//p[2]')
  end

  it "should determine when attributes are removed" do
    changes = added_attr.at('div').diff(removed_attr.at('div')).to_a

    changes.length.should == 3

    changes[0][0].should == ' '
    changes[0][1].should == added_attr.at('p')

    changes[1][0].should == '-'
    changes[1][1].should == added_attr.at('//p/@id')

    changes[2][0].should == ' '
    changes[2][1].should == added_attr.at('//p/text()')
  end

  context ":added" do
    it "should determine only when text nodes are added" do
      changes = doc.at('div').diff(added_text.at('div'), :added => true).to_a

      changes.length.should == 1

      changes[0][0].should == '+'
      changes[0][1].should == added_text.at('//div/text()')
    end

    it "should determine only when elements are added" do
      changes = doc.at('div').diff(added_element.at('div'), :added => true).to_a

      changes.length.should == 1

      changes[0][0].should == '+'
      changes[0][1].should == added_element.at('//div/p[2]')
    end

    it "should determine only when attributes are added" do
      changes = doc.at('div').diff(added_attr.at('div'), :added => true).to_a

      changes.length.should == 1

      changes[0][0].should == '+'
      changes[0][1].should == added_attr.at('//p/@id')
    end
  end

  context ":removed" do
    it "should determine only when text nodes are removed" do
      changes = doc.at('div').diff(removed_text.at('div'), :removed => true).to_a

      changes.length.should == 1

      changes[0][0].should == '-'
      changes[0][1].should == doc.at('//p/text()')
    end

    it "should determine only when elements are added" do
      changes = doc.at('div').diff(removed_element.at('div'), :removed => true).to_a

      changes.length.should == 1

      changes[0][0].should == '-'
      changes[0][1].should == doc.at('//div/p')
    end

    it "should determine only when attributes are added" do
      changes = doc.at('div').diff(added_attr.at('div'), :removed => true).to_a

      changes.length.should == 1

      changes[0][0].should == '-'
      changes[0][1].should == doc.at('//p/@id')
    end
  end
end
