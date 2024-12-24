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
  
  def solve
    longest_chain = []
    full_size = @items.values.flatten.size
    @items.values.flatten.each_with_index do |item, i|
      current_chain = dfs item
      puts "#{i}/#{full_size}"
      p current_chain
      puts
      longest_chain = current_chain if current_chain.size > longest_chain.size
    end
    p longest_chain
  end
  
  private

  def dfs(node, visited = [])
    visited << node
    longest_chain = [node]
    @items[node.tail].reject {|i| visited.include? i}.each do |neighbor|
      chain = dfs neighbor, visited
      longest_chain = [node] + chain if chain.size + 1 > longest_chain.size
    end
    visited.pop
    longest_chain
  end
end

class Node 
  def initialize(item)
    @item = item
  end
  
  def head
    @item[0, 2].to_sym
  end

  def tail
    @item[-2, 2].to_sym
  end
  
  def inspect
    @item
  end
end

filename = "source.txt"
numbers = File.readlines(filename, chomp: true)
puzzle = Puzzle.new numbers
puzzle.solve