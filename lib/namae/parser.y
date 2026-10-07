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
       | u_words von last opt_suffices opt_titles
       {
         result = Name.new(
           :given => val[0], :particle => val[1], :family => val[2], :suffix => val[3], :title => val[4]
         )
       }
       | von last opt_suffices opt_titles
       {
         result = Name.new(
           :particle => val[0], :family => val[1], :suffix => val[2], :title => val[3]
         )
       }
       | NICK u_words word opt_suffices opt_titles
       {
         result = Name.new(
           :nick => val[0], :given => val[1], :family => val[2], :suffix => val[3], :title => val[4]
         )
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
        | words NICK               { result = { :given => val[0], :nick => val[1] } }
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
    :separator => %w[and & ;].freeze,
    :et_al => /\s*\b(et\s+al\b\.?|and\s+others\b)\s*\z/i,
    :pronoun => %w[
      he him his she her hers they them their theirs
      xe xem xyr ze zir hir er ihm sie ihr
    ].freeze,
    :title => [
      'Lt Col', 'Lt Gen', 'Maj Gen', 'Brig Gen', *%w[
      Sir Dame Lord Lady Count Countess Baroness Hon.
      General Gen. Admiral Adm Colonel Col. Maj. Captain Capt
      Commander Cmdr Lieutenant Lt Sergeant Sgt Cpl Pvt
      Reverend Rev Pr Father Sister Brother Deaconess Rabbi Vicar
      Archbishop Msgr Professor Prof Doctor Dr
    ]].freeze,
    :trailing_title => %w[
      PhD Ph.D DPhil EdD Ed.D PsyD MD M.D DDS DVM JD J.D RN Esq
    ].freeze,
    :suffix => /\s*\b(JR|Jr|jr|JNR|Jnr|jnr|SR|Sr|sr|SNR|Snr|snr|[IVX]{2,}|[1-9]\d*(st|nd|rd|th))(\.|\b)/,
    :appellation => /\s*\b((mrs?|mx|ms|fr|hr|mme|mlle)\.?|miss|herr|frau)(\s+|$)/i,
    :uppercase_particle => /\s*\b(D[aiu]|De[rs]?|St\.?|Saint|La|Les|V[ao]n)(\s+|$)/
  }

  class << self
    attr_reader :defaults

    # Yields a writable copy of the default options. The new defaults
    # apply to all parsers created afterwards, including each thread's
    # parser instance. List values are frozen: assign a new list instead
    # of changing it in place (e.g., `options[:title] += %w[Sen]`).
    def configure
      options = defaults.dup
      yield options
      @defaults = freeze_options(options)
    end

    # @return [Parser] the current thread's parser, which is replaced
    #   when the defaults change.
    def instance
      parser = Thread.current[:namae]
      parser = Thread.current[:namae] = new unless parser&.defaults.equal?(defaults)
      parser
    end

    def freeze_options(options)
      options.transform_values { |value| value.frozen? ? value : value.dup.freeze }.freeze
    end
  end

  @defaults = freeze_options(@defaults)

  attr_reader :options, :defaults, :input,
    :separator, :title, :trailing_title, :trailing_titles, :single_word, :pronouns

  # @param options [Hash] options that override the current defaults;
  #   the parser's options cannot be changed later.
  def initialize(options = {})
    @defaults = self.class.defaults
    @options = self.class.freeze_options(defaults.merge(options))
    @input = StringScanner.new('')
    compile_patterns
  end

  def debug?
    options[:debug] || ENV['DEBUG']
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

  def et_al
    options[:et_al]
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
    options[:prefer_comma_as_separator] && !@single
  end

  def parse(string)
    parse!(string)
  rescue => e
    warn e.message if debug?
    Names.new
  end

  # @param single [Boolean] whether the input is a single name, in which
  #   case commas never separate names.
  def parse!(string, single: false)
    @input = StringScanner.new(normalize(string))
    @single = single
    reset
    names = Names.new(do_parse)
    names.map(&:merge_particles!) if include_particle_in_family?
    names.others = @others
    @pronouns_of.each { |index, pronouns| names[index]&.pronouns = pronouns }
    names
  end

  # Adds an honorific to a name, keeping titles on both sides of the name.
  def honor(name, honorific)
    titles = [honorific.title, name.title].compact
    name.merge(honorific)
    name.title = titles.join(' ') unless titles.empty?
    name
  end

  # Compiles the patterns derived from the options.
  def compile_patterns
    # Separator words (e.g., 'and') match as whole words only, symbols
    # (e.g., '&') need no word boundaries.
    @separator = pattern(:separator) do |words|
      words = words.map do |word|
        word.match?(/\A[[:alnum:]]+\z/) ? "\\b#{Regexp.escape(word)}\\b" : Regexp.escape(word)
      end
      /\s*(#{words.join('|')})\s*/i
    end

    # Titles precede the name; trailing titles follow it, optionally
    # after a comma.
    @title = pattern(:title) do |words|
      /\s*\b(#{titles(words)})(?=\s|\z)\s*/i
    end
    @trailing_title = pattern(:trailing_title) do |words|
      /\s*\b(#{titles(words)})(?![^\s#{stops}])\s*/i
    end

    # Pronouns in parentheses (e.g., '(he/him)'): at least two words, all
    # of them pronouns, separated by slashes or commas.
    @pronouns = pattern(:pronoun) do |words|
      pronoun = /\b(#{words.map { |word| Regexp.escape(word) }.join('|')})\b/i
      /\s*\(\s*(#{pronoun}(\s*[\/,]\s*#{pronoun})+)\s*\)/
    end

    end_of_name = /(#{separator}|\s*#{comma}|\s*\z)/
    @trailing_titles = /(#{trailing_title})+#{end_of_name}/
    @single_word = /[^\s#{stops}]+#{end_of_name}/
  end

  # @return [Regexp] the option itself if it is a pattern; otherwise the
  #   pattern the block builds from the option's list of words.
  def pattern(key)
    value = options[key]
    value.is_a?(Regexp) ? value : yield(value)
  end

  # A trailing period is optional unless the title itself ends with one.
  def titles(words)
    # Longer titles first, so that 'Lt Col' wins over 'Lt'.
    words.sort_by { |word| -word.length }.map { |word|
      word.end_with?('.') ? Regexp.escape(word) : "#{Regexp.escape(word)}\\.?"
    }.join('|')
  end

  def normalize(string)
    string.scrub.strip
  end

  def reset
    @commas, @words, @initials, @suffices, @yydebug = 0, 0, 0, 0, debug?
    @seen_initial = false

    # Titles and appellations are not counted as words; they are only
    # recognized while leading (at the start of a name or the given part
    # of a sort-order name) or, for trailing titles, at the end of a name.
    @leading = true
    @others = false
    @pending = nil
    @name_index = 0
    @pronouns_of = {}
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
    @seen_initial = false
    @leading = true
    @name_index += 1
    [:AND, :AND]
  end

  def consume_comma
    @commas += 1
    @leading = true
    [:COMMA, :COMMA]
  end

  def consume_word(type, word)
    @words += 1
    @particle_first = %i[LWORD UPARTICLE].include?(type) if @words == 1
    @leading = false
    @initial = false

    case type
    when :UWORD
      @initials += 1 if word.match?(/^[[:upper:]]+\b/)
      # Only single letters or dotted letters (e.g., 'G', 'J.', 'J.A.')
      # count as initials here, not all-caps words (e.g., 'LEWIS').
      @initial = word.match?(/\A([[:upper:]]\.?|([[:upper:]]\.)+)\z/)
      @seen_initial ||= @initial
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
    @words >= 2 && input.check(trailing_titles)
  end

  def will_see_initial?
    input.rest.strip.split(/\s+/)[0] =~ /^[[:upper:]]+\b/
  end

  # A comma ends the current name if the name is complete: either it
  # has initials before the last word (e.g., "J. Smith" can only be in
  # display order) or, if commas are preferred as separators, it has
  # at least two words, does not start with a particle (e.g., "Da Silva,
  # Luiz Inácio"), and is not followed by initials or a single word (e.g.,
  # "Brinch Hansen, Per").
  def seen_full_name?
    return false if will_see_suffix?
    return true if @seen_initial && !@initial

    prefer_comma_as_separator? && @words > 1 && !@particle_first &&
      (@initials > 0 || !will_see_initial?) && !will_see_single_word?
  end

  def will_see_single_word?
    input.check(single_word)
  end

  def next_token
    if @pending
      token, @pending = @pending, nil
      return token
    end

    case
    when input.nil?, input.eos?
      nil
    when input.scan(pronouns)
      # Pronouns are not part of the grammar: keep them for the current name.
      @pronouns_of[@name_index] = input[1]
      next_token
    when input.scan(et_al)
      @others = true
      nil
    when input.scan(separator)
      consume_separator
    when input.scan(/\s*#{comma}\s*/)
      if last_token == :COMMA || input.check(separator) || input.check(et_al) ||
          will_see_trailing_titles?
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
      suffix = input.matched.strip
      if @commas.zero? && (@words == 1 || @particle_first) && input.check(/\s*#{comma}/)
        # Read 'Gump Jr., Bubba' as 'Gump, Jr., Bubba'.
        token = consume_comma
        @pending = consume_word(:SUFFIX, suffix)
        token
      else
        consume_word(:SUFFIX, suffix)
      end
    when input.scan(uppercase_particle)
      consume_word(:UPARTICLE, input.matched.strip)
    when input.scan(/((\\\w+)?\{[^\}]*\})*[[:upper:]][^\s#{stops}]*/)
      consume_word(:UWORD, input.matched)
    when input.scan(/((\\\w+)?\{[^\}]*\})*[[:lower:]][^\s#{stops}]*/)
      consume_word(:LWORD, input.matched)
    when input.scan(/(\\\w+)?\{[^\}]*\}[^\s#{stops}]*/)
      consume_word(:PWORD, input.matched)
    when input.scan(/('[^'\n]+')|("[^"\n]+")|(\(\s*['"]?[[:upper:]][^()\d.\n]*\))/)
      # Nicknames in quotes or parentheses, e.g., 'Mike', (Mike) or ('Mike');
      # in parentheses, they must not look like '(ed.)' or '(2001)'.
      consume_word(:NICK, input.matched[1...-1].strip.sub(/\A(['"])(.*)\1\z/, '\\2'))
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
