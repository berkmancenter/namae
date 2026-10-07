# -*- ruby -*-
# vi: set ft=ruby :

class Namae::Parser

token COMMA UWORD LWORD PWORD NICK AND APPELLATION TITLE SUFFIX UPARTICLE

expect 0

rule

  names :                { result = [] }
        | name           { result = [val[0]] }
        | names AND name { result = val[0] << val[2] }

  name : word            { result = Name.new(:given => val[0]) }
       | word suffices   { result = Name.new(:given => val[0], :suffix => val[1]) }
       | display_order
       | honorific word          { result = val[0].merge(:family => val[1]) }
       | honorific display_order { result = honor(val[1], val[0]) }
       | sort_order
       | honorific sort_order    { result = honor(val[1], val[0]) }

  honorific : APPELLATION        { result = Name.new(:appellation => val[0]) }
            | titles             { result = Name.new(:title => val[0]) }
            | APPELLATION titles { result = Name.new(:appellation => val[0], :title => val[1]) }

  display_order : u_words word opt_suffices opt_titles
       {
         result = Name.new(
           :given => val[0], :family => val[1], :suffix => val[2], :title => val[3]
         )
       }
       | u_words NICK last opt_suffices opt_titles
       {
         result = Name.new(
           :given => val[0], :nick => val[1], :family => val[2], :suffix => val[3], :title => val[4]
         )
       }
       | u_words NICK von last opt_suffices opt_titles
       {
         result = Name.new(
           :given => val[0], :nick => val[1], :particle => val[2], :family => val[3], :suffix => val[4], :title => val[5])
       }
       | u_words von last
       {
         result = Name.new(:given => val[0], :particle => val[1], :family => val[2])
       }
       | von last
       {
         result = Name.new(:particle => val[0], :family => val[1])
       }

  sort_order : last COMMA first
       {
         result = Name.new(val[2].merge(:family => val[0]), !!val[2][:suffix])
       }
       | von last COMMA first
       {
         result = Name.new(val[3].merge(
           :particle => val[0], :family => val[1]
         ), !!val[3][:suffix])
       }
       | u_words von last COMMA first
       {
         result = Name.new(val[4].merge(
           :particle => val[0,2].join(' '), :family => val[2]
         ), !!val[4][:suffix])
       }
       ;

  von : particle
      | von particle         { result = val.join(' ') }
      | von u_words particle { result = val.join(' ') }

  particle : LWORD | UPARTICLE

  last : LWORD | u_words

  first : /* empty */                    { result = {} }
        | titles                         { result = { :title => val[0] } }
        | given opt_titles               { result = val[0].merge(:title => val[1]) }
        | honorific given opt_titles
          {
            titles = [val[0].title, val[2]].compact
            result = val[1].merge(val[0].to_h.compact)
            result[:title] = titles.join(' ') unless titles.empty?
          }

  given : words                    { result = { :given => val[0] } }
        | words opt_comma suffices { result = { :given => val[0], :suffix => val[2] } }
        | suffices                 { result = { :suffix => val[0] } }
        | suffices COMMA words     { result = { :given => val[2], :suffix => val[0] } }

  u_words : u_word
          | u_words u_word { result = val.join(' ') }

  u_word : UWORD | PWORD

  words : word
        | words word { result = val.join(' ') }

  opt_comma : /* empty */ | COMMA

  word : LWORD | UWORD | PWORD | UPARTICLE

  opt_suffices : /* empty */ | suffices

  suffices : SUFFIX
           | suffices SUFFIX { result = val.join(' ') }

  opt_titles : /* empty */ | titles

  titles : TITLE
         | titles TITLE { result = val.join(' ') }

---- header
require 'strscan'

---- inner

  @defaults = {
    :debug => false,
    :prefer_comma_as_separator => false,
    :include_particle_in_family => false,
    :comma => ',',
    :stops => ',;',
    :separator => /\s*(\band\b|\&|;)\s*/i,
    :title => %w[
      Sir Dame Lord Lady Count Countess Baroness Hon.
      General Gen. Admiral Adm Colonel Col. Maj. Captain Capt
      Commander Cmdr Lieutenant Lt Sergeant Sgt Cpl Pvt
      Reverend Rev Pr Father Sister Brother Deaconess Rabbi Vicar
      Archbishop Msgr Professor Prof Doctor Dr
    ],
    :trailing_title => %w[
      PhD Ph.D DPhil EdD Ed.D PsyD MD M.D DDS DVM JD J.D RN Esq
    ],
    :suffix => /\s*\b(JR|Jr|jr|JNR|Jnr|jnr|SR|Sr|sr|SNR|Snr|snr|[IVX]{2,}|[1-9]\d*(st|nd|rd|th))(\.|\b)/,
    :appellation => /\s*\b((mrs?|mx|ms|fr|hr|mme|mlle)\.?|miss|herr|frau)(\s+|$)/i,
    :uppercase_particle => /\s*\b(D[aiu]|De[rs]?|St\.?|Saint|La|Les|V[ao]n)(\s+|$)/
  }

  class << self
    attr_reader :defaults

    def instance
      Thread.current[:namae] ||= new
    end
  end

  attr_reader :options, :input

  def initialize(options = {})
    @options = self.class.defaults.merge(options)
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

  def include_particle_in_family?
    options[:include_particle_in_family]
  end

  def stops
    options[:stops]
  end

  # Titles precede the name.
  def title
    memo(:title, options[:title]) do
      compile(options[:title], /(?=\s|\z)\s*/)
    end
  end

  # Trailing titles follow the name, optionally after a comma.
  def trailing_title
    memo(:trailing_title, options[:trailing_title], stops) do
      compile(options[:trailing_title], /(?![^\s#{stops}])\s*/)
    end
  end

  def suffix
    options[:suffix]
  end

  def appellation
    options[:appellation]
  end

  def uppercase_particle
    options[:uppercase_particle]
  end

  def prefer_comma_as_separator?
    options[:prefer_comma_as_separator]
  end

  def parse(string)
    parse!(string)
  rescue => e
    warn e.message if debug?
    []
  end

  def parse!(string)
    @input = StringScanner.new(normalize(string))
    reset
    names = do_parse
    names.map(&:merge_particles!) if include_particle_in_family?
    names
  end

  # Adds an honorific to a name, keeping titles on both sides of the name.
  def honor(name, honorific)
    titles = [honorific.title, name.title].compact
    name.merge(honorific)
    name.title = titles.join(' ') unless titles.empty?
    name
  end

  def compile(words, boundary)
    return words if words.is_a?(Regexp)

    # A trailing period is optional unless the word itself ends with one.
    words = words.map { |word| word.end_with?('.') ? Regexp.escape(word) : "#{Regexp.escape(word)}\\.?" }
    /\s*\b(#{words.join('|')})#{boundary}/i
  end

  # Caches patterns derived from options; the key includes the option
  # values so that changing an option invalidates the cached pattern.
  def memo(*key)
    (@memo ||= {})[key] ||= yield
  end

  def normalize(string)
    string.scrub.strip
  end

  def reset
    @commas, @words, @initials, @suffices, @yydebug = 0, 0, 0, 0, debug?

    # Titles and appellations are not counted as words; they are only
    # recognized while leading (at the start of a name or the given part
    # of a sort-order name) or, for trailing titles, at the end of a name.
    @leading = true
    self
  end

  private

  def stack
    @vstack || @racc_vstack || []
  end

  def last_token
    stack[-1]
  end

  def consume_separator
    return next_token if seen_separator?
    @commas, @words, @initials, @suffices = 0, 0, 0, 0
    @leading = true
    [:AND, :AND]
  end

  def consume_comma
    @commas += 1
    @leading = true
    [:COMMA, :COMMA]
  end

  def consume_word(type, word)
    @words += 1
    @leading = false

    case type
    when :UWORD
      @initials += 1 if word =~ /^[[:upper:]]+\b/
    when :SUFFIX
      @suffices += 1
    end

    [type, word]
  end

  def seen_separator?
    !stack.empty? && last_token == :AND
  end

  def suffix?
    !@suffices.zero? || will_see_suffix?
  end

  def will_see_suffix?
    input.rest.strip.split(/\s+/)[0] =~ suffix
  end

  # Trailing titles must follow at least two name words and end the name.
  def will_see_trailing_titles?
    @words >= 2 &&
      input.check(memo(:trailing_titles, trailing_title, separator, comma) {
        /(#{trailing_title})+(#{separator}|\s*#{comma}|\s*\z)/
      })
  end

  def will_see_initial?
    input.rest.strip.split(/\s+/)[0] =~ /^[[:upper:]]+\b/
  end

  def seen_full_name?
    prefer_comma_as_separator? && @words > 1 &&
      (@initials > 0 || !will_see_initial?) && !will_see_suffix?
  end

  def next_token
    case
    when input.nil?, input.eos?
      nil
    when input.scan(separator)
      consume_separator
    when input.scan(/\s*#{comma}\s*/)
      if last_token == :COMMA || will_see_trailing_titles?
        next_token
      elsif @commas.zero? && !seen_full_name? || @commas == 1 && suffix?
        consume_comma
      else
        consume_separator
      end
    when input.scan(/\s+/)
      next_token
    when @leading && input.scan(title)
      [:TITLE, input.matched.strip]
    when @leading && input.scan(appellation)
      [:APPELLATION, input.matched.strip]
    when will_see_trailing_titles? && input.scan(trailing_title)
      [:TITLE, input.matched.strip]
    when input.scan(suffix)
      consume_word(:SUFFIX, input.matched.strip)
    when input.scan(uppercase_particle)
      consume_word(:UPARTICLE, input.matched.strip)
    when input.scan(/((\\\w+)?\{[^\}]*\})*[[:upper:]][^\s#{stops}]*/)
      consume_word(:UWORD, input.matched)
    when input.scan(/((\\\w+)?\{[^\}]*\})*[[:lower:]][^\s#{stops}]*/)
      consume_word(:LWORD, input.matched)
    when input.scan(/(\\\w+)?\{[^\}]*\}[^\s#{stops}]*/)
      consume_word(:PWORD, input.matched)
    when input.scan(/('[^'\n]+')|("[^"\n]+")/)
      consume_word(:NICK, input.matched[1...-1])
    when input.scan(/[@\d][^\s#{stops}]*[[:alpha:]][^\s#{stops}]*/)
      # Handles and other words starting with @ or a digit
      consume_word(:PWORD, input.matched)
    else
      raise ArgumentError,
        "Failed to parse name #{input.string.inspect}: unmatched data at offset #{input.pos}"
    end
  end

  def on_error(tid, value, stack)
    raise ArgumentError,
      "Failed to parse name: unexpected '#{value}' at #{stack.inspect}"
  end

# -*- racc -*-
