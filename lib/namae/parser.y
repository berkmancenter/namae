# -*- racc -*-

class Namae::Parser

token COMMA UWORD LWORD PWORD NICK AND

expect 0

rule

  names :                { result = [] }
        | name           { result = [val[0]] }
        | names AND name { result << val[2] }

  name : word
       {
         result = Name.new(:given => val[0])
       }
       | u_words word
       {
         result = Name.new(:given => val[0], :family => val[1])
       }
       | u_words NICK last
       {
         result = Name.new(:given => val[0], :nick => val[1], :family => val[2])
       }
       | u_words NICK von last
       {
         result = Name.new(:given => val[0], :nick => val[1],
           :particle => val[2], :family => val[3])
       }
       | u_words von last
       {
         result = Name.new(:given => val[0], :particle => val[1], :family => val[2])
       }
       | von last
       {
         result = Name.new(:particle => val[0], :family => val[1])
       }
       | last COMMA first
       {
         result = Name.new(:family => val[0], :suffix => val[2][0],
           :given => val[2][1])
       }
       | von last COMMA first
       {
         result = Name.new(:particle => val[0], :family => val[1],
           :suffix => val[3][0], :given => val[3][1])
       }
       | u_words von last COMMA first
       {
         result = Name.new(:particle => val[0,2].join(' '), :family => val[2],
           :suffix => val[4][0], :given => val[4][1])
       }
       ;

  von : LWORD
      | von LWORD         { result = val.join(' ') }
      | von u_words LWORD { result = val.join(' ') }

  last : LWORD | u_words

  first : opt_words                 { result = [nil,val[0]] }
        | opt_words COMMA opt_words { result = [val[0],val[2]] }

  u_words : u_word
          | u_words u_word { result = val.join(' ') }

  u_word : UWORD | PWORD

  words : word
        | words word { result = val.join(' ') }
  
  opt_words : /* empty */ | words

  word : LWORD | UWORD | PWORD


---- header
require 'singleton'
require 'strscan'

---- inner

  include Singleton
    
  attr_reader :options
  
  def initialize
    @input, @options = StringScanner.new(''), {
      :debug => false,
      :comma => ',',
      :separator => /\s+(?:and|&)\s+/i
    }
  end
  
  def debug?
    options[:debug] || ENV['DEBUG']
  end
  
  def separator
    options[:separator]
  end
  
  def comma
    options[:comma]
  end
  
  def parse(input)
    parse!(input)
  rescue => e
    warn e.message if debug?
    []
  end
  
  def parse!(string)
    @yydebug = debug?
    input.string = string.strip
    do_parse
  end
    
  private
  
  def next_token
    case
    when input.nil?, input.eos?
      nil
    when input.scan(separator)
      [:AND, nil]
    when input.scan(/\s*,\s*/)
      [:COMMA, nil]
    when input.scan(/\s+/)
      next_token
    when input.scan(/\p{Upper}[^\s#{comma}]*/)
      [:UWORD, input.matched]
    when input.scan(/\p{Lower}[^\s#{comma}]*/)
      [:LWORD, input.matched]
    when input.scan(/('[^'\n]+')|("[^"\n]+")/)
      [:NICK, input.matched[1...-1]]
    else
      raise ArgumentError,
        "Failed to parse name #{input.string.inspect}: unmatched data at offset #{input.pos}"
    end
  end
  
  def match_word(word)
  end
  
  def on_error(tid, value, stack)
    raise ArgumentError,
      "Failed to parse name: unexpected '#{value}' at #{stack.inspect}"
  end
    
  attr_reader :input

# -*- racc -*-