# encoding: utf-8
require_relative "scripts/dictionary.rb"
arg = ARGV.join(" ").force_encoding("UTF-8")
Dictionary.new.lookup(arg).output
