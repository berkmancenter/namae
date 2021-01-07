module Namae
  module Version
    MAJOR = 1
    MINOR = 0
    PATCH = 2
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.').freeze
  end
end
