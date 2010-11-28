require 'nokogiri/diff/xml/node'

class Nokogiri::XML::Document < Nokogiri::XML::Node

  #
  # Overrides `tdiff` to only compare the child nodes of the document.
  #
  def tdiff(tree,&block)
    return enum_for(:tdiff,tree) unless block

    tdiff_recursive(tree,&block)
    return self
  end

  #
  # Overrides `tdiff_unordered` to only compare the child nodes of the document.
  #
  def tdiff_unordered(tree,&block)
    return enum_for(:tdiff_unordered,tree) unless block

    tdiff_recursive_unordered(tree,&block)
    return self
  end

end
