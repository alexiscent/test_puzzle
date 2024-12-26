#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"

class Puzzle
  def initialize(items, **options)
    @options = options
    @items_by_head = items.each_with_object(Hash.new { |h, k| h[k] = [] }) do |i, h|
      node = Node.new i, **options
      raise ArgumentError, "overlap bigger than some items" if node.item.length < overlap
      h[node.head] << node
    end
    @solution = []
  end

  def solve
    return solution unless @solution.empty?

    @items_by_head.values.flatten.each do |item|
      current_chain = find_longest item
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

  # basically a depth-first search
  def find_longest(node)
    node.visited = true
    longest_chain = [node]
    @items_by_head[node.tail].each do |neighbor|
      next if neighbor.visited?

      chain = find_longest neighbor
      longest_chain = chain.prepend(node) if chain.size + 1 > longest_chain.size
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

  def initialize(item, **options)
    @item = item.to_s
    @visited = false
    @options = options
  end

  def head
    @head ||= @item[0, overlap].to_sym
  end

  def tail
    @tail ||= @item[-overlap..].to_sym
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

if __FILE__ == $0
  options = {file: "source.txt", overlap: 2}
  parser = OptionParser.new
  parser.on("-fNAME", "--file NAME", "input file (default: #{options[:file]})", String) do |file|
    file
  end
  parser.on("-oNUMBER", "--overlap NUMBER", "edge overlap (default: #{options[:overlap]})", Integer) do |overlap|
    raise RangeError, "overlap is not positive" unless overlap.positive?

    overlap
  end

  begin
    parser.parse!(into: options)
    numbers = File.readlines(options[:file], chomp: true).reject(&:empty?)
  rescue RangeError, OptionParser::InvalidArgument
    puts "Overlap must be a positive integer"
  rescue OptionParser::MissingArgument
    puts parser
  rescue Errno::ENOENT
    puts "File '#{options[:file]}' does not exist"
  rescue Errno::EACCES
    puts "Could not read from '#{options[:file]}: Permission denied'"
  else
    begin
      puzzle = Puzzle.new numbers, **options.slice(:overlap)
    rescue ArgumentError => e
      puts "Could not create puzzle: #{e.message}"
    else
      puzzle.solve
      puts puzzle.formatted_solution
    end
  end
end
