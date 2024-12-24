#!/usr/bin/env ruby
# frozen_string_literal: true

class Puzzle
  def initialize(items)
    @items = items.each_with_object(Hash.new { |h, k| h[k] = [] }) do |i, h|
      node = Node.new i
      h[node.head] << node
    end
  end

  def solve
    longest_chain = []
    full_size = @items.values.flatten.size
    @items.values.flatten.each_with_index do |item, i|
      current_chain = dfs item
      longest_chain = current_chain if current_chain.size > longest_chain.size
    end
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
end

class Node
  attr_writer :visited
  attr_reader :item

  def initialize(item)
    @item = item.to_s
    @visited = false
  end

  def head
    @item[0, 2].to_sym
  end

  def tail
    @item[-2, 2].to_sym
  end

  def to_s
    @item
  end

  def visited?
    @visited
  end
end

filename = "source.txt"
numbers = File.readlines(filename, chomp: true)
puzzle = Puzzle.new numbers
puzzle.solve