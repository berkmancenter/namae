# -*- racc -*-

class Namae::Parser

token COMMA UWORD LWORD PWORD NICK AND APPELLATION TITLE

expect 0

rule

  names :                { result = [] }
        | name           { result = [val[0]] }
        | names AND name { result = val[0] << val[2] }

  name : word            { result = Name.new(:given => val[0]) }
       | display_order
       | honorific word          { result = val[0].merge(:family => val[1]) }
       | honorific display_order { result = val[1].merge(val[0]) }
       | sort_order
  
  honorific : APPELLATION { result = Name.new(:appellation => val[0]) }
            | TITLE       { result = Name.new(:title => val[0]) }
            
  display_order : u_words word
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
         result = Name.new(:given => val[0], :particle => val[1],
          :family => val[2])
       }
       | von last
       {
         result = Name.new(:particle => val[0], :family => val[1])
       }
       
  sort_order : last COMMA first
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
      :separator => /\s*(\band\b|\&)\s*/i,
      :title => /\s*\b(sir|lord|(prof|dr|md|ph\.?d)\.?)(\s+|$)/i,
      :suffix => /\s*\b(jr|sr|[ivx]+)\.?\s*/i,
      :appellation => /\s*\b((mrs?|ms|fr|hr)\.?|miss|herr|frau)(\s+|$)/i
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

  def title
    options[:title]
  end

  def suffix
    options[:suffix]
  end

  def appellation
    options[:appellation]
  end
  
  def parse(input)
    parse!(input)
  rescue => e
    warn e.message if debug?
    []
  end
  
  def parse!(string)
    input.string = normalize(string)
    reset
    do_parse
  end
  
  def normalize(string)
    string = string.strip
    string
  end
  
  def reset
    @commas, @yydebug = 0, debug?   
    self
  end

  private
    
  def consume_separator
    @commas = 0
    [:AND, nil]
  end
  
  def consume_comma
    @commas += 1
    [:COMMA, nil]
  end
  
  def seen_suffix?
    return false unless @vstack
    return true if @vstack[-1].nil?
    @vstack[-1] =~ suffix
  end

  def next_token
    case
    when input.nil?, input.eos?
      nil
    when input.scan(separator)
      consume_separator
    when input.scan(/\s*,\s*/)
      if @commas.zero? || @commas == 1 && seen_suffix?
        consume_comma
      else
        consume_separator
      end
    when input.scan(/\s+/)
      next_token
    when input.scan(title)
      [:TITLE, input.matched.strip]
    when input.scan(appellation)
      [:APPELLATION, input.matched.strip]
    when input.scan(/((\\\w+)?\{[^\}]*\})*[[:upper:]][^\s#{comma}]*/)
      [:UWORD, input.matched]
    when input.scan(/((\\\w+)?\{[^\}]*\})*[[:lower:]][^\s#{comma}]*/)
      [:LWORD, input.matched]
    when input.scan(/(\\\w+)?\{[^\}]*\}[^\s#{comma}]*/)
      [:PWORD, input.matched]
    when input.scan(/('[^'\n]+')|("[^"\n]+")/)
      [:NICK, input.matched[1...-1]]
    else
      raise ArgumentError,
        "Failed to parse name #{input.string.inspect}: unmatched data at offset #{input.pos}"
    end
  end
    
  def on_error(tid, value, stack)
    raise ArgumentError,
      "Failed to parse name: unexpected '#{value}' at #{stack.inspect}"
  end
    
  attr_reader :input

# -*- racc -*-