# nokogiri-diff

* [Source](http://github.com/postmodern/nokogiri-diff)
* [Issues](http://github.com/postmodern/nokogiri-diff/issues)
* Postmodern (postmodern.mod3 at gmail.com)

## Description

nokogiri-diff adds the ability to calculate the differences (added or
removed nodes) between two XML/HTML documents.

## Features

* Performs a breadth-first comparison between children nodes.
* Compares XML/HTML Elements, Attributes, Text nodes and DTD nodes.
* Allows calculating differences between documents, or just enumerating the
  added or removed nodes.

## Examples

    require 'nokogiri/diff'

## Requirements

* [tdiff](http://github.com/postmodern/tdiff) ~> 0.3.2
* [nokogiri](http://nokogiri.rubyforge.org/) ~> 1.4.1

## Install

    $ gem install nokogiri-diff

## Copyright

Copyright (c) 2010 Hal Brodigan

See {file:LICENSE.txt} for details.
