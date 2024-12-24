#!/usr/bin/env ruby
# frozen_string_literal: true

class Puzzle
  def initialize(items)
    @items = items.reduce(Hash.new { |h, k| h[k] = [] }) do |h, i|
      node = Node.new i
      h[node.head] << node
      h
    end
  end
end

class Node 
  def initialize(item)
    @item = item
  end
  
  def head
    @item[0, 2].to_sym
  end
end

filename = "source.txt"
numbers = File.readlines(filename, chomp: true)
puzzle = Puzzle.new numbers