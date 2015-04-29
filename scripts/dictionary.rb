# encoding: utf-8
# set encoding to UTF-8 since Alfred's default is US-ASCII
Encoding::default_external = Encoding::UTF_8 if defined? Encoding

require "sqlite3"
require "uri"
require_relative "helpers.rb"
load "scripts/storage.rb"

class Dictionary
  def initialize
    @wb = Path::dic_wb
    @limit = Path::limit

    @content = [] # output content
    @items = [] # wordpairs to display
    @storage = Storage.new
    self
  end

  def output

    title_id = 0
    subtitle_id = 1

    if @items.count > 0

      if @items.first[0].downcase.include? @input.downcase
        title_id = 1
        subtitle_id = 0
      end

      # items to content
      @items.each do |row|
        icon = 0
        icon = 1 if @storage.check(row[1], row[0])
        add_item_valid(row[title_id], row[subtitle_id], getarg(row[1], row[0]), icon)
      end
    end

    puts '<?xml version="1.0" encoding="utf-8"?>'
    puts "<items>"
    @content.each { |line| puts line }
    puts "</items>"
  end

  # returns the storage in a way that alfred can read
  def getstorage
    @storage.get.each do |wordpair|
      wordpair[0].each do |word|
        add_item_valid(word, wordpair[1], getarg(word, wordpair[1]), 1)
      end
    end

    self
  end

  def lookup(input)
    if input.length < 3
      add_item_novalid("Please enter min. 3 chars...")
      self
    end

    # store input for later use
    @input = input

    title_id = nil
    subtitle_id = nil

    SQLite3::Database.new(@wb)
    .execute("select content from wb_idx where content MATCH '#{input}*' limit 1000") do |row|
      # repairing
      row = row[0].strip
      next if row.empty?

      @items.push row.split("\t").push 0 # add virtual column -> used for rating relevancy
    end

    if @items.count == 0
      add_item_novalid("Nothing found for #{input}...") 
    else
      sort_items
      @items = @items[0..@limit - 1] # cut results to limit
    end

    self
  end

  # checks if iput is exactly on of the words in given chain
  # eg. waive/to waive = true BUT waive/waiver = false
  def rate_item_part_exactinclude(chain)
    chain.downcase.split(" ").each do |word|
      return true if word==@input.downcase
    end
    return false
  end

  def rate_item_part(part)

    # seems stupid but this was the case for the verb "spielen"
    return 1000 if not part.is_a? String

    # exact match
    return 0 if part.downcase == @input.downcase

    pos = part.downcase.index(@input.downcase)

    # no match (usually for one part in a row)
    pos = 0 if not pos

    # add penalty points if word is not exctly included
    pos = 100 if not rate_item_part_exactinclude(part)

    # position + length
    return pos + part.length

  end

  def rate_item(item)
    item[2] = rate_item_part(item[0])+rate_item_part(item[1])
    item
  end

  def sort_items
    @items.map! { |i| rate_item(i) }
    @items.sort_by! { |i| i[2] }
    # @items.each { |i| puts i }
  end

  def getarg(*arg)
    URI.escape(arg[0]) + "===" + URI.escape(arg[1])
  end

  def add_item_novalid(text)
    @content.push "<item valid=\"no\">"
    @content.push "<title>#{text}</title>"
    @content.push "<icon>de_en.png</icon>"
    @content.push "</item>"
  end

  def add_item_valid(title, subtitle, arg, icon = 0)
    @content.push "<item valid=\"yes\" arg=\"#{arg}\">"
    @content.push "<title>#{title}</title>"
    @content.push "<subtitle>#{subtitle}</subtitle>"
    @content.push "<icon>#{icon}.png</icon>"
    @content.push "</item>"
  end
end
