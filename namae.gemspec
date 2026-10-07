# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'namae/version'

Gem::Specification.new do |s|
  s.name = 'namae'
  s.version = Namae::Version::STRING.dup
  s.homepage = 'https://github.com/berkmancenter/namae'
  s.email = ['sylvester@keil.or.at']
  s.authors = ['Sylvester Keil']
  s.licenses = ['AGPL-3.0-or-later', 'BSD-2-Clause']

  s.summary =
    'Namae (名前) parses personal names and splits them into their component parts.'

  s.description = %q{
    Namae (名前) is a parser for human names. It recognizes personal names of
    various cultural backgrounds and tries to split them into their component
    parts (e.g., given and family names, honorifics etc.).
  }.gsub(/\s+/, ' ')

  s.required_ruby_version = '>= 3.1'
  s.add_dependency('racc', '~> 1.7')

  s.require_path = 'lib'

  s.rdoc_options = %w{
    --line-numbers
    --inline-source
    --title 'Namae'
    --main README.md
    --exclude lib/namae/parser.rb
  }
  s.extra_rdoc_files = %w{README.md AGPL BSDL}

  s.files = `git ls-files -- lib`.split("\n") + %w[AGPL BSDL README.md]
end
