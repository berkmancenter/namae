Namae (名前)
==========
Namae is a parser for human names. It recognizes personal names of various
cultural backgrounds and tries to split them into their component parts
(e.g., given and family names, honorifics etc.).

[![CI](https://github.com/berkmancenter/namae/actions/workflows/ci.yml/badge.svg)](https://github.com/berkmancenter/namae/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/namae.svg)](https://badge.fury.io/rb/namae)

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

Rails
-----
It is easy to integrate Namae into your Rails project. There are two typical
cases where this might be useful: you want to store individual parts of a
person's name in your database, but want to provide your user's with a single
input field; or else, you keep personal names in a single database column
but your application occasionally requires access to individual parts.

For the latter use case, there is a straightforward way to add Namae to your
Rails model:

    class Person < ActiveRecord::Base
      attr_accessible :name

      delegate :family, :initials, :to => :namae

      private

      def namae
        @namae ||= Namae::Name.parse(name)
      end
    end

In this minimal example, we are using the method `Namae::Name.parse` which
always returns a single Name instance and delegate all readers for the name's
parts in which we are interested to this instance.

Format and Examples
-------------------
Namae recognizes names in a wide variety of two basic formats, internally
referred to as display-order and sort-order. For example, the following
names are written in display-order:

    Namae.parse 'Charles Babbage'
    #-> [#<Name family="Babbage" given="Charles">]

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

    Namae.parse 'Ms. Sofia Kovaleskaya'
    #-> [#<Name family="Kovaleskaya" given="Sofia" appellation="Ms.">]

    Namae.parse 'Countess Ada Lovelace'
    #-> [#<Name family="Lovelace" given="Ada" title="Countess">]

    Namae.parse 'Ken Griffey Jr.'
    #-> [#<Name family="Griffey" given="Ken" suffix="Jr.">]

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

Namae tries to detect common particles using the `:uppercase_particle` lexer
pattern. If you prefer to always include particles with the family name, you
can set the `:include_particle_in_family` parser option.

    Namae.parse 'Ludwig von Beethoven'
    #-> [#<Name family="Beethoven" given="Ludwig" particle="von">]

    Namae.configure { |options| options[:include_particle_in_family] = true }
    Namae.parse 'Ludwig von Beethoven'
    #-> [#<Name family="von Beethoven" given="Ludwig">]

Configuration
-------------
You can tweak some of Namae's parse rules by configuring the parser's
options. Take a look at `Namae.options` to see your current settings.
The options are read-only; to change them, run `Namae.configure`, which
yields a writable copy of the default options and applies the result to
all parsers (list values are frozen, so assign new lists instead of
changing them in place):

    Namae.configure do |options|
      options[:prefer_comma_as_separator] = true
    end

To use different options for a single parser instead, pass them to
`Namae::Parser.new`; a parser's options cannot be changed later.

Titles are configured as lists of words: `:title` for titles that precede
the name (e.g., 'Dr', 'Sir') and `:trailing_title` for titles that follow
it (e.g., 'PhD', 'MD').
Words that double as names (e.g., 'Elder', 'Pastor' or 'Cantor')
are left out of the defaults, so adjust the lists to your data:

    Namae.configure do |options|
      options[:title] = options[:title] - %w[Lord] + %w[Elder Sen]
      options[:trailing_title] += %w[MBA]
    end

    Namae.parse 'Sen. Jane Doe, MBA'
    #-> [#<Name family="Doe" given="Jane" title="Sen. MBA">]

Names in a list are separated by 'and', '&' or ';'. To parse lists in
other languages, add the corresponding words (some, like Spanish 'y',
also join the parts of a single name, so add them with care):

    Namae.configure { |options| options[:separator] += %w[und] }
    Namae.parse 'Max Weber und Karl Marx'
    #-> [#<Name family="Weber" given="Max">, #<Name family="Marx" given="Karl">]

In lists, a comma may separate two names or the family and given names
of a single name. Namae uses initials and the number of words to tell
these apart; when that is not enough (e.g., 'John Smith, Jane Doe'), it
reads the comma as part of a sort-order name by default. Set the
`:prefer_comma_as_separator` option to read it as a separator instead:

    Namae.parse 'John Smith, Jane Doe'
    #-> [#<Name family="John Smith" given="Jane Doe">]

    Namae.configure { |options| options[:prefer_comma_as_separator] = true }
    Namae.parse 'John Smith, Jane Doe'
    #-> [#<Name family="Smith" given="John">, #<Name family="Doe" given="Jane">]

Nicknames are recognized in quotes or parentheses, and pronouns in
parentheses when all their words are in the `:pronoun` list:

    Namae.parse 'Sam (Sammy) Doe (they/them)'
    #-> [#<Name family="Doe" given="Sam" nick="Sammy" pronouns="they/them">]

A list ending in 'et al.' or 'and others' is marked as such:

    Namae.parse('Smith, John, et al.').others?
    #-> true

A Note On Thread Safety
-----------------------
When using the top-level parse functions, Namae will re-use a thread-local
parser instance (`Namae::Parser.instance`); the instance is created, using
the current default options (`Namae::Parser.defaults`), and replaced when
the defaults change. If you need more control, you are encouraged to create
individual parser instances using `Namae::Parser.new`.


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
[Personal Names Around the World](https://www.w3.org/International/questions/qa-personal-names).

Development
-----------
The Namae source code is [hosted on GitHub](https://github.com/berkmancenter/namae).
You can check out a copy of the latest code using Git:

    $ git clone https://github.com/berkmancenter/namae.git

To get started, install the dependencies and run all tests:

    $ cd namae
    $ bundle install
    $ bundle exec rake

If you change the grammar in `lib/namae/parser.y`,
regenerate the parser with `bundle exec rake racc`.

If you've found a bug or have a question, please open an issue on the
[issue tracker](https://github.com/berkmancenter/namae/issues). Or, for extra
credit, clone the Namae repository, write a failing example, fix the bug
and submit a pull request.

Contributors
------------
* [Sylvester Keil](http://sylvester.keil.or.at)
* Dan Collis-Puro

Credits
-------
Namae was written as a part of a Google Summer of Code project. Thanks Google!

Copyright
---------
Copyright (c) 2013-2026 Sylvester Keil

Copyright (c) 2012 President and Fellows of Harvard College.

Namae is dual licensed under the AGPL and a BSD-style license.
