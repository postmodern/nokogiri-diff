# nokogiri-diff

* [Source](https://github.com/postmodern/nokogiri-diff)
* [Issues](https://github.com/postmodern/nokogiri-diff/issues)
* [Documentation](http://rubydoc.info/gems/nokogiri-diff/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

nokogiri-diff adds the ability to calculate the differences (added or
removed nodes) between two XML/HTML documents.

## Features

* Performs a breadth-first comparison between children nodes.
* Compares XML/HTML Elements, Attributes, Text nodes and DTD nodes.
* Allows calculating differences between documents, or just enumerating the
  added or removed nodes.

## Examples

Enumerate over the the differences between two HTML documents:

    require 'nokogiri/diff'

    doc1 = Nokogiri::HTML('<div><p>one</p> two </div>')
    doc2 = Nokogiri::HTML('<div><p id="1">one</p> <p>three</p></div>')

    doc1.diff(doc2) do |change,node|
      puts "#{change} #{node.to_html}".ljust(30) + node.parent.path
    end

    #   <div>
    # <p>one</p> two </div> /
    #   <p>one</p>                  /div
    # -  two                        /div
    # +                             /div
    # + <p>three</p>                /div
    # +  id="1"                     /div/p[1]
    #   one                         /div/p

Only find the added nodes:

    doc1.diff(doc2, :added => true) do |change,node|
      puts node.to_html.ljust(30) + node.parent.path
    end

    #                               /div
    # <p>three</p>                  /div
    #  id="1"                       /div/p[1]

Only find the removed nodes:

    doc1.diff(doc2, :removed => true) do |change,node|
      puts node.to_html.ljust(30) + node.parent.path
    end

    #  two                          /div

## Requirements

* [ruby](http://www.ruby-lang.org/) >= 1.8.7
* [tdiff](http://github.com/postmodern/tdiff) ~> 0.3.2
* [nokogiri](http://nokogiri.rubyforge.org/) ~> 1.5

## Install

    $ gem install nokogiri-diff

## Copyright

Copyright (c) 2010-2012 Hal Brodigan

See {file:LICENSE.txt} for details.
