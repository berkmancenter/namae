Namae
=====
Namae is a parser for human names. It recognizes personal names of various
cultural backgrounds and tries to split them into their component parts
(e.g., given and family names, honorifics etc.).

Quickstart
----------
1. Install the namae gem (or add it to your Gemfile):

        $ gem install namae

2. Start parsing names! Namae expects you to pass in a string and it returns
   a list of parsed names:

        require 'namae'
        
        names = Namae.parse 'Yukihiro "Matz" Matsumoto'
        
        names[0].family #=> Matsumoto
        names[0].nick #=> Matz
        names[0].given #=> Yukihiro

Copyright
---------
Copyright (c) 2012 President and Fellows of Harvard College.
Please see LICENSE for further details.