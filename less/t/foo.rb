#!/usr/bin/env ruby

def ohai *args
  puts args.collect { |a| a.upcase+"\n" }
end

ohai *ARGV
