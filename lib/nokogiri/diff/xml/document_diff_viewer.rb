class Nokogiri::XML::Node

  class DifferenceViewer
    def difference_view(previous_doc, current_doc)
      doc1 = previous_doc.xpath("/html/body")
      doc2 = current_doc.xpath("/html/body")
      compare_nodes(doc1[0], doc2[0])
    end

    def compare_nodes(node1, node2, parent_node = Nokogiri::HTML(''), step =0)

      if (not (node1.nil? or node2.nil?) and (node1.class == node2.class) and (node1.name == node2.name))

        #Creating a new node (of same name) and adding it to parent_node, then updating attributes
        case node2.class.name
          when Nokogiri::XML::Element.name
            _node2 = Nokogiri::XML::Element.new node2.name, parent_node
            node2.attributes.each do |attr_name, attr|
              _node2.set_attribute(attr_name, attr.value)
            end
            add_class(_node2, 'style_attrs_modified') unless are_attributes_common?(node1, node2)
            add_to_parent(parent_node, _node2)

            max_child_node_count = (node1.children.count >= node2.children.count) ? node1.children.count : node2.children.count
            for i in 1..max_child_node_count
              compare_nodes(node1.children[i-1], node2.children[i-1], _node2, step+=1)
            end
          when Nokogiri::XML::Text.name
            if node1.to_s == node2.to_s
              _node2 = Nokogiri::XML::Text.new node2.to_s, parent_node
              add_to_parent(parent_node, _node2)
            else
              _node1 = Nokogiri::XML::Text.new node1.to_s, parent_node
              add_to_parent(parent_node, _node1, 't_style_removed')

              _node2 = Nokogiri::XML::Text.new node2.to_s, parent_node
              add_to_parent(parent_node, _node2, 't_style_added')
            end
        end
      else
        #puts "Nodes are different"
        unless node1.nil?
          add_to_parent(parent_node, node1.clone, 'e_style_removed') if node1.class == Nokogiri::XML::Element
          add_to_parent(parent_node, node1.clone, 't_style_removed') if node1.class == Nokogiri::XML::Text
        end
        unless node2.nil?
          add_to_parent(parent_node, node2.clone, 'e_style_added') if node2.class == Nokogiri::XML::Element
          add_to_parent(parent_node, node2.clone, 't_style_added') if node2.class == Nokogiri::XML::Text
        end
      end
      #puts "parent_node_result : #{parent_node}"
      parent_node
    end

    def add_to_parent(parent_node, child_node, css_class= nil)
      if child_node.nil?
      elsif Nokogiri::XML::Element == child_node.class
        add_class(child_node, css_class) unless css_class.nil?
        parent_node.add_child(child_node)
      elsif Nokogiri::XML::Text == child_node.class
        if css_class.nil?
          parent_node.add_child(child_node)
        else
          parent_node.add_child("<span class='#{css_class}'>#{child_node.to_html}</span>")
        end
      else
        raise 'UnHandlableClassType'
      end
    end

    def add_class(node, css_class)
      node.set_attribute('class', [node.get_attribute('class').to_s.split(' '), css_class].flatten.uniq.compact.join(' '))
    end

    def are_attributes_common?(node1, node2)
      _flag_attrs_common = true
      (node1.attributes.keys + node2.attributes.keys).flatten.uniq.compact.each do |key|
        _flag_attrs_common = (_flag_attrs_common and if node1.attributes[key].nil? or node2.attributes[key].nil?
                                                       false
                                                     else
                                                       (node1.attributes[key].value == node2.attributes[key].value)
                                                     end)
      end
      _flag_attrs_common
    end
  end

end