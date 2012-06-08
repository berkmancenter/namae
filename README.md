Namae
=====
Namae is a parser for human names. It recognizes personal names of various
cultural backgrounds and tries to split them into their component parts
(e.g., given and family names, honorifics etc.).

[![Build Status](https://secure.travis-ci.org/berkmancenter/namae.png)](http://travis-ci.org/berkmancenter/namae)

Quickstart
----------
1. Install the namae gem (or add it to your Gemfile):

        $ gem install namae

2. Start parsing names! Namae expects you to pass in a string and it returns
   a list of parsed names:

        require 'namae'
        
        names = Namae.parse 'Yukihiro "Matz" Matsumoto'
        #-> [#<Name family="Matsumoto" given="Yukihiro" nick="Matz">]

3. Use the name objects to access the individual parts:

        matz = names[0]
        
        matz.nick
        #-> "Matz"
        
        matz.family
        #-> "Matsumoto"
        
        matz.initials
        #-> "Y.M."
        
        matz.initials :expand => true
        #-> "Y. Matsumoto"
        
        matz.initials :dots => false
        #-> "YM"

Format and Examples
-------------------
Namae recognizes names in a wide variety of two basic formats, internally
referred to as display-order and sort-order. For example, the following
names are written in display-order:

    Namae.parse 'Charles Babbage'
    #-> [#<Name family="Babbage" given="Charles">]]

    Namae.parse 'Mr. Alan M. Turing'
    #-> [#<Name family="Turing" given="Alan M." appellation="Mr.">]

    Namae.parse 'Yukihiro "Matz" Matsumoto'
    #-> [#<Name family="Matsumoto" given="Yukihiro" nick="Matz">]

    Namae.parse 'Augusta Ada King and Lord Byron'
    #-> [#<Name family="King" given="Augusta Ada">, #<Name family="Byron" title="Lord">]

    Namae.parse 'Sir Isaac Newton'
    #-> [#<Name family="Newton" given="Isaac" title="Sir">]

    Namae.parse 'Prof. Donald Ervin Knuth'
    #-> [#<Name family="Knuth" given="Donald Ervin" title="Prof.">]
    
Or in sort-order:

    Namae.parse 'Turing, Alan M.'
    #-> [#<Name family="Turing" given="Alan M.">]

You can also mix sort- and display-order in the same expression:

    Namae.parse 'Torvalds, Linus and Alan Cox'
    #-> [#<Name family="Torvalds" given="Linus">, #<Name family="Cox" given="Alan">]

Typically, sort-order names are easier to parse, because the syntax is less
ambiguous. For example, multiple family names are always possible in sort-order:

    Namae.parse 'Carreño Quiñones, María-Jose'
    #-> [#<Name family="Carreño Quiñones" given="María-Jose">]

Whilst in display-order, multiple family names are only supported when the
name contains a particle or a nickname.


Rationale
---------
Parsing human names is at once too easy and too hard. When working in the
confines of a single language or culture it is often a trivial task that
does not warrant a dedicated software package; when working across different
cultures, languages, or scripts, however, it may quickly become unrealistic
to devise a satisfying, one-size-fits-all solution. In languages like
Japanese or Chinese, for instance, the issue of word segmentation alone is
probably more difficult than name parsing itself.

Having said that, Namae is based on the rules used by BibTeX to format names
and can therefore be used to parse names of most languages using latin
script with the long-time goal to support as many languages and scripts as
possible without the need for sophisticated or large dictionary based
language-detection or word segmentation features.

For further reading, see the W3C's primer on
[Personal Names Around the World](http://www.w3.org/International/questions/qa-personal-names).

Development
-----------
The Namae source code is [hosted on GitHub](https://github.com/berkmancenter/namae).
You can check out a copy of the latest code using Git:

    $ git clone https://github.com/berkmancenter/namae.git
    
To get started, generate the parser and run all tests:

    $ cd namae
    $ bundle install
    $ rake racc
    $ rake features
    $ rake spec

If you've found a bug or have a question, please open an issue on the
[issue tracker](https://github.com/berkmancenter/namae/issues). Or, for extra
credit, clone the Namae repository, write a failing example, fix the bug
and submit a pull request.

Contributors
------------
* [Sylvester Keil](http://sylvester.keil.or.at)
* Dan Collis-Puro

Copyright
---------
Copyright (c) 2012 President and Fellows of Harvard College.

Namae is dual licensed under the AGPL and a BSD-style license.
