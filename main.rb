#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"

class Puzzle
  def initialize(items, options)
    @options = options.dup.freeze
    @items = items.each_with_object(Hash.new { |h, k| h[k] = [] }) do |i, h|
      node = Node.new i, @options
      h[node.head] << node
    end
    @solution = []
  end

  def solve
    return solution unless @solution.empty?

    @items.values.flatten.each do |item|
      current_chain = dfs item
      @solution = current_chain if current_chain.size > @solution.size
    end

    solution
  end

  def solution
    @solution.map { |node| node.to_s }
  end

  def formatted_solution
    solution.reduce { |res, str| res << str[overlap..] }
  end

  private

  def dfs(node)
    node.visited = true
    longest_chain = [node]
    @items[node.tail].each do |neighbor|
      next if neighbor.visited?

      chain = dfs neighbor
      longest_chain = [node] + chain if chain.size + 1 > longest_chain.size
    end
    node.visited = false
    longest_chain
  end

  def overlap
    @options[:overlap]
  end
end

class Node
  attr_writer :visited
  attr_reader :item

  def initialize(item, options)
    @item = item.to_s
    @visited = false
    @options = options
  end

  def head
    @item[0, overlap].to_sym
  end

  def tail
    @item[-overlap..].to_sym
  end

  def to_s
    @item
  end

  def visited?
    @visited
  end

  private

  def overlap
    @options[:overlap]
  end
end

def parse_options
  options = {filename: "source.txt", overlap: 2}
  parser = OptionParser.new do |parser|
    parser.on("-fNAME", "--file NAME", "input file (default: #{options[:filename]})", String) do |filename|
      options[:filename] = filename
    end
    parser.on("-oNUMBER", "--overlap NUMBER", "edge overlap (default: #{options[:overlap]})", Integer) do |overlap|
      raise RangeError, "overlap is not positive" unless overlap.positive?

      options[:overlap] = overlap
    end
  end
  parser.parse!(into: options)
  options
end

begin
  options = parse_options
  numbers = File.readlines(options[:filename], chomp: true)
rescue RangeError, OptionParser::InvalidArgument
  puts "Overlap must be a positive integer"
rescue Errno::ENOENT
  puts "File '#{options[:filename]}' does not exist"
rescue Errno::EACCES
  puts "Could not read from '#{options[:filename]}: Permission denied'"
else
  puzzle = Puzzle.new numbers, options.slice(:overlap)
  puzzle.solve
  puts puzzle.formatted_solution
end
