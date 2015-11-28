require 'spec_helper'
require 'nokogiri/diff'

describe "nokogiri/diff" do
  let(:contents) { '<div><p>one</p></div>' }
  let(:doc)      { Nokogiri::XML(contents) }

  let(:added_text)    { Nokogiri::XML('<div><p>one</p>two</div>') }
  let(:added_element) { Nokogiri::XML('<div><p>one</p><p>two</p></div>') }
  let(:added_attr)    { Nokogiri::XML('<div><p id="1">one</p></div>') }
  let(:added_attrs)   { Nokogiri::XML('<div><p id="1" class="2">one</p></div>') }

  let(:changed_text)       { Nokogiri::XML('<div><p>two</p></div>') }
  let(:changed_element)    { Nokogiri::XML('<div><span>one</span></div>') }
  let(:changed_attr_name)  { Nokogiri::XML('<div><p i="1">one</p></div>') }
  let(:changed_attr_value) { Nokogiri::XML('<div><p id="2">one</p></div>') }
  let(:changed_attr_order) { Nokogiri::XML('<div><p class="2" id="1">one</p></div>') }

  let(:removed_text)    { Nokogiri::XML('<div><p></p>two</div>') }
  let(:removed_element) { Nokogiri::XML('<div></div>') }
  let(:removed_attr)    { Nokogiri::XML('<div><p>one</p></div>') }

  it "should add #diff to Nokogiri::XML::Docuemnt" do
    expect(doc).to respond_to(:diff)
  end

  it "should add #diff to Nokogiri::XML::Element" do
    expect(added_element.at('div')).to respond_to(:diff)
  end

  it "should add #diff to Nokogiri::XML::Text" do
    expect(added_text.at('p/text()')).to respond_to(:diff)
  end

  it "should add #diff to Nokogiri::XML::Attr" do
    expect(added_attr.at('p/@id')).to respond_to(:diff)
  end

  it "should not compare the Document objects" do
    change = doc.diff(doc).first

    expect(change[0]).to eq(' ')
    expect(change[1]).to eq(doc.root)
  end

  it "should determine when two different documents are identical" do
    expect(doc.diff(Nokogiri::XML(contents)).all? { |change,node|
      change == ' '
    }).to eq(true)
  end

  it "should search down within Nokogiri::XML::Document objects" do
    expect(doc.diff(changed_text).any? { |change,node|
      change != ' '
    }).to eq(true)
  end

  it "should determine when text nodes are added" do
    changes = doc.at('div').diff(added_text.at('div')).to_a

    expect(changes.length).to eq(4)

    expect(changes[0][0]).to eq(' ')
    expect(changes[0][1]).to eq(doc.at('div'))

    expect(changes[1][0]).to eq(' ')
    expect(changes[1][1]).to eq(doc.at('//p'))

    expect(changes[2][0]).to eq('+')
    expect(changes[2][1]).to eq(added_text.at('//div/text()'))

    expect(changes[3][0]).to eq(' ')
    expect(changes[3][1]).to eq(doc.at('//p/text()'))
  end

  it "should determine when elements are added" do
    changes = doc.at('div').diff(added_element.at('div')).to_a

    expect(changes.length).to eq(5)

    expect(changes[0][0]).to eq(' ')
    expect(changes[0][1]).to eq(doc.at('div'))

    expect(changes[1][0]).to eq('+')
    expect(changes[1][1]).to eq(added_element.at('//p[1]'))

    expect(changes[2][0]).to eq(' ')
    expect(changes[2][1]).to eq(doc.at('//p'))

    expect(changes[3][0]).to eq('-')
    expect(changes[3][1]).to eq(doc.at('//p/text()'))

    expect(changes[4][0]).to eq('+')
    expect(changes[4][1]).to eq(added_element.at('//p[2]/text()'))
  end

  it "should ignore when attribute order changes" do
    changes = added_attrs.at('p').diff(changed_attr_order.at('p')).to_a

    expect(changes.all? { |change| change[0] == ' ' }).to be_truthy
  end

  it "should determine when attributes are added" do
    changes = doc.at('p').diff(added_attr.at('p')).to_a

    expect(changes.length).to eq(3)

    expect(changes[0][0]).to eq(' ')
    expect(changes[0][1]).to eq(doc.at('p'))

    expect(changes[1][0]).to eq('+')
    expect(changes[1][1]).to eq(added_attr.at('//p/@id'))

    expect(changes[2][0]).to eq(' ')
    expect(changes[2][1]).to eq(doc.at('//p/text()'))
  end

  it "should determine when text nodes differ" do
    changes = doc.at('p').diff(changed_text.at('p')).to_a

    expect(changes.length).to eq(3)

    expect(changes[0][0]).to eq(' ')
    expect(changes[0][1]).to eq(doc.at('p'))

    expect(changes[1][0]).to eq('-')
    expect(changes[1][1]).to eq(doc.at('//p/text()'))

    expect(changes[2][0]).to eq('+')
    expect(changes[2][1]).to eq(changed_text.at('//p/text()'))
  end

  it "should determine when element names differ" do
    changes = doc.at('div').diff(changed_element.at('div')).to_a

    expect(changes.length).to eq(3)

    expect(changes[0][0]).to eq(' ')
    expect(changes[0][1]).to eq(doc.at('div'))

    expect(changes[1][0]).to eq('-')
    expect(changes[1][1]).to eq(doc.at('p'))

    expect(changes[2][0]).to eq('+')
    expect(changes[2][1]).to eq(changed_element.at('span'))
  end

  it "should determine when attribute names differ" do
    changes = added_attr.at('p').diff(changed_attr_name.at('p')).to_a

    expect(changes.length).to eq(4)

    expect(changes[0][0]).to eq(' ')
    expect(changes[0][1]).to eq(added_attr.at('p'))

    expect(changes[1][0]).to eq('-')
    expect(changes[1][1]).to eq(added_attr.at('//p/@id'))

    expect(changes[2][0]).to eq('+')
    expect(changes[2][1]).to eq(changed_attr_name.at('//p/@i'))

    expect(changes[3][0]).to eq(' ')
    expect(changes[3][1]).to eq(added_attr.at('//p/text()'))
  end

  it "should determine when attribute values differ" do
    changes = added_attr.at('p').diff(changed_attr_value.at('p')).to_a

    expect(changes.length).to eq(4)

    expect(changes[0][0]).to eq(' ')
    expect(changes[0][1]).to eq(added_attr.at('p'))

    expect(changes[1][0]).to eq('-')
    expect(changes[1][1]).to eq(added_attr.at('//p/@id'))

    expect(changes[2][0]).to eq('+')
    expect(changes[2][1]).to eq(changed_attr_value.at('//p/@id'))

    expect(changes[3][0]).to eq(' ')
    expect(changes[3][1]).to eq(added_attr.at('//p/text()'))
  end

  it "should determine when text nodes are removed" do
    changes = added_text.at('div').diff(removed_text.at('div')).to_a

    expect(changes.length).to eq(4)

    expect(changes[0][0]).to eq(' ')
    expect(changes[0][1]).to eq(added_text.at('div'))

    expect(changes[1][0]).to eq(' ')
    expect(changes[1][1]).to eq(added_text.at('p'))

    expect(changes[2][0]).to eq(' ')
    expect(changes[2][1]).to eq(added_text.at('//div/text()'))

    expect(changes[3][0]).to eq('-')
    expect(changes[3][1]).to eq(added_text.at('//p/text()'))
  end

  it "should determine when elements are removed" do
    changes = added_element.at('div').diff(removed_element.at('div')).to_a

    expect(changes.length).to eq(3)

    expect(changes[0][0]).to eq(' ')
    expect(changes[0][1]).to eq(added_element.at('div'))

    expect(changes[1][0]).to eq('-')
    expect(changes[1][1]).to eq(added_element.at('//p[1]'))

    expect(changes[2][0]).to eq('-')
    expect(changes[2][1]).to eq(added_element.at('//p[2]'))
  end

  it "should ignore when attributes change order" do
  end

  it "should determine when attributes are removed" do
    changes = added_attr.at('div').diff(removed_attr.at('div')).to_a

    expect(changes.length).to eq(4)

    expect(changes[0][0]).to eq(' ')
    expect(changes[0][1]).to eq(added_attr.at('div'))

    expect(changes[1][0]).to eq(' ')
    expect(changes[1][1]).to eq(added_attr.at('p'))

    expect(changes[2][0]).to eq('-')
    expect(changes[2][1]).to eq(added_attr.at('//p/@id'))

    expect(changes[3][0]).to eq(' ')
    expect(changes[3][1]).to eq(added_attr.at('//p/text()'))
  end

  context ":added" do
    it "should determine only when text nodes are added" do
      changes = doc.at('div').diff(added_text.at('div'), :added => true).to_a

      expect(changes.length).to eq(1)

      expect(changes[0][0]).to eq('+')
      expect(changes[0][1]).to eq(added_text.at('//div/text()'))
    end

    it "should determine only when elements are added" do
      changes = doc.at('div').diff(added_element.at('div'), :added => true).to_a

      expect(changes.length).to eq(1)

      expect(changes[0][0]).to eq('+')
      expect(changes[0][1]).to eq(added_element.at('//div/p[2]'))
    end

    it "should determine only when attributes are added" do
      changes = doc.at('div').diff(added_attr.at('div'), :added => true).to_a

      expect(changes.length).to eq(1)

      expect(changes[0][0]).to eq('+')
      expect(changes[0][1]).to eq(added_attr.at('//p/@id'))
    end
  end

  context ":removed" do
    it "should determine only when text nodes are removed" do
      changes = doc.at('div').diff(removed_text.at('div'), :removed => true).to_a

      expect(changes.length).to eq(1)

      expect(changes[0][0]).to eq('-')
      expect(changes[0][1]).to eq(doc.at('//p/text()'))
    end

    it "should determine only when elements are removed" do
      changes = doc.at('div').diff(removed_element.at('div'), :removed => true).to_a

      expect(changes.length).to eq(1)

      expect(changes[0][0]).to eq('-')
      expect(changes[0][1]).to eq(doc.at('//div/p'))
    end

    it "should determine only when attributes are removed" do
      changes = added_attr.at('div').diff(removed_attr.at('div'), :removed => true).to_a

      expect(changes.length).to eq(1)

      expect(changes[0][0]).to eq('-')
      expect(changes[0][1]).to eq(added_attr.at('//p/@id'))
    end
  end
end
