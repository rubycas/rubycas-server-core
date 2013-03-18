require 'active_support/core_ext/hash'
require 'active_support/hash_with_indifferent_access'
require "rubycas-server-core/core_ext/string"

String.send(:include, RubyCAS::Server::Core::String)
