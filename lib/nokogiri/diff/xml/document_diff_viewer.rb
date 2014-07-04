class Nokogiri::XML::Node
  def difference_view(doc, &block)
    node_hash ||= {}
    result_doc = self.clone
    self.diff(doc) do |change, node|
      (node_hash[node.parent] ||= []) << {change: change, node: node} if ['+', '-'].include?(change)
    end

    node_hash.each do |k, vv|
      _k_path = k.path

      vv.reverse.each do |v|
        _nodes = result_doc.xpath(v[:node].path)
        _node = _nodes[0]

        if v[:change] == "+"
          if Nokogiri::XML::Attr == v[:node].class
            _p = result_doc.xpath(doc.xpath(_k_path)[0].path)[0]
            doc.xpath(_k_path)[0].attributes.each do |attr_name, attr_node|
              _p.set_attribute(attr_name, attr_node.value)
            end
            add_class(_p, 'diff_attr_added')
          elsif Nokogiri::XML::Element == v[:node].class
            _child_index_in_doc = doc.xpath(_k_path).children.collect { |x| x.path }.index(v[:node].path) || 0
            _t_ccount = result_doc.xpath(_k_path).children.count
            _child_node = result_doc.xpath(_k_path).children[a = (_child_index_in_doc <= _t_ccount ? _child_index_in_doc : (_t_ccount-1))]
            if _child_node.nil?
              #doc3.xpath(_k_path)[0].add_child("<SPAN class='diff_added'>#{v[:node].to_html}</SPAN>")
              add_class(v[:node], 'diff_added')
              result_doc.xpath(_k_path)[0].add_child(v[:node].to_html)
            else
              #_child_node.add_previous_sibling("<SPAN class='diff_added'>#{v[:node].to_html}</SPAN>")
              add_class(v[:node], 'diff_added')
              _child_node.add_previous_sibling(v[:node].to_html)
            end
          elsif Nokogiri::XML::Text == v[:node].class
            _child_index_in_doc = doc.xpath(_k_path).children.collect { |x| x.path }.index(v[:node].path) || 0
            _t_ccount = result_doc.xpath(_k_path).children.count
            _child_node = result_doc.xpath(_k_path).children[a = (_child_index_in_doc <= _t_ccount ? _child_index_in_doc : (_t_ccount-1))]
            if _child_node.nil?
              result_doc.xpath(_k_path)[0].add_child("{{{[#{v[:change]}]#{v[:node].to_html}}}}")
            else
              _child_node.add_next_sibling("{{{[#{v[:change]}]#{v[:node].to_html}}}}")
            end
          end
        elsif v[:change] == "-"
          if Nokogiri::XML::Attr == v[:node].class
            _p = _node.parent
            add_class(_p, 'diff_attr_deleted')
          elsif Nokogiri::XML::Element == v[:node].class
            add_class(v[:node], 'diff_deleted')
            _node.replace(v[:node].to_html)
          elsif Nokogiri::XML::Text == v[:node].class
            _node.replace("{{{[#{v[:change]}]#{v[:node].to_html}}}}")
          end
        end
      end

    end
    if block_given?
      yield(result_doc)
    else
      result_doc
    end
  end

  def formatted_diff_view(doc, added_class = 'added', removed_class = 'removed')
    difference_view(doc) do |updated_doc|
      updated_doc.to_html.to_s.split("}}}").collect do |_string|
        _string.gsub(/{{{\[([+-]+)\]([\x00-\x7F]*)/) { |x| "<span class='#{$1=='+' ? added_class : removed_class}'>#{$2}</span>" }
      end.join
    end
  end

  def add_class(node, css_class)
    node.set_attribute('class', [node.get_attribute('class').to_s.split(' '), css_class].flatten.uniq.compact.join(' '))
  end
end