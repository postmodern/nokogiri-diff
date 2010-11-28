require 'nokogiri'
require 'tdiff'

class Nokogiri::XML::Node

  include TDiff
  include TDiff::Unordered

  #
  # Compares two XML/HTML nodes.
  #
  # @param [Nokogiri::XML::Node] node1
  #
  # @param [Nokogiri::XML::Node] node2
  #
  # @return [Boolean]
  #   Specifies whether the two nodes are equal.
  #
  def tdiff_equal(node)
    if (self.class == node.class)
      case node
      when Nokogiri::XML::Document
        self.root.tdiff_equal(node.root)
      when Nokogiri::XML::Attr
        (self.name == node.name && self.value == node.value)
      when Nokogiri::XML::Element
        self.name == node.name
      when Nokogiri::XML::Text
        self.text == node.text
      else
        false
      end
    else
      false
    end
  end

  #
  # Enumerates over the children of a XML/HTML node.
  #
  # @param [Nokogiri::XML::Node] node
  # 
  # @yield [child]
  #   The given block will be passed every child of the node.
  #
  # @yieldparam [Nokogiri::XML::Node] node
  #   A child node.
  #
  def tdiff_each_child(node,&block)
    if node.kind_of?(Nokogiri::XML::Element)
      node.attribute_nodes.each(&block)
    end

    node.children.each(&block)
  end

  #
  # Finds the differences between the node and another node.
  #
  # @param [Nokogiri::XML::Node] other
  #   The other node to compare against.
  #
  # @param [Hash] options
  #   Additional options for filtering changes.
  #
  # @option options [Boolean] :added
  #   Yield nodes that were added.
  #
  # @option options [Boolean] :removed
  #   Yield nodes that were removed.
  #
  # @yield [change, node]
  #   The given block will be passed each changed node.
  #
  # @yieldparam [' ', '-', '+'] change
  #   Indicates whether the node stayed the same, was removed or added.
  #
  # @yieldparam [Nokogiri::XML::Node] node
  #   The changed node.
  #
  # @return [Enumerator]
  #   If no block was given, an Enumerator object will be returned.
  #
  def diff(other,options={},&block)
    return enum_for(:diff,other,options) unless block

    if (options[:added] || options[:removed])
      tdiff_unordered(other) do |change,node|
        if (change == '+' && options[:added])
          yield change, node
        elsif (change == '-' && options[:removed])
          yield change, node
        end
      end
    else
      tdiff(other,&block)
    end
  end

end
