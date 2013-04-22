### 0.2.0 / 2013-04-22

* {Nokogiri::XML::Node#tdiff_each_child} now sorts attributes by name, so that
  changes in attribute order is ignored. (thanks @bhollis)
* {Nokogiri::XML::Node#tdiff_equal} now supports `Nokogiri::XML::Comment`
  and `Nokogiri::XML::ProcessingInstruction` objects. (thanks @bhollis)

### 0.1.2 / 2012-05-28

* Require tdiff ~> 0.3, >= 0.3.2.
* Added {Nokogiri::Diff::VERSION}.
* Replaced ore-tasks with
  [rubygems-tasks](https://github.com/postmodern/rubygems-tasks#readme).

### 0.1.1 / 2012-05-09

* Require nokogiri ~> 1.5.

### 0.1.0 / 2010-11-29

* Initial release:
  * Performs a breadth-first comparison between children nodes.
  * Compares XML/HTML Elements, Attributes, Text nodes and DTD nodes.
  * Allows calculating differences between documents, or just enumerating
    the added or removed nodes.

