module Namae
  module Version
    MAJOR = 1
    MINOR = 1
    PATCH = 0
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.').freeze
  end
end
