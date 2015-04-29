# encoding: utf-8
# set encoding to UTF-8 since Alfred's default is US-ASCII
Encoding::default_external = Encoding::UTF_8 if defined? Encoding

require "sqlite3"
require "uri"
require_relative "helpers.rb"

class Storage
  def initialize
    @file = Path::file
    @wb = Path::dic_wb
    @limit = Path::limit

    # format for words:
    # word_de1,word_de2,word_enx /t word_en1,word_en2,word_enx
    @words_left = []
    @words_right = []
    initwords
  end

  # read all words from file
  def initwords
    return if not @file
    return if not File.file?(@file)
    content = File.new(@file).read
    content.split("\n").each do |line|
      pair = line.split("\t")
      @words_left.push pair[0].split(",")
      @words_right.push pair[1].split(",")
    end
  end

  # used from alfred's workflow input
  # arg="word1===word2"
  def toggle(arg)
    args = URI.unescape(arg).force_encoding("utf-8").split("===")
    if not check(args[0], args[1])
      add(args[0], args[1])
    else
      remove(args[0], args[1])
    end
  end

  # remove word pair
  def remove(word1, word2)
    pos = check(word1, word2)
    return false if not pos

    if @words_left[pos].count == 1 && @words_right[pos].count == 1
      # delete line if there's only this one word pair
      @words_left.delete_at pos
      @words_right.delete_at pos
    elsif @words_left[pos].count > 1 && @words_right[pos].count > 1
      # remove both words if there are multiple words on both sides
      @words_left[pos].delete_at @words_left[pos].index(word1)
      @words_right[pos].delete_at @words_right[pos].index(word2)
    else
      # remove only one word if there are multiple assignments
      # find out no which side to delete (side with > 1 words)
      if @words_left[pos].count > 1
        @words_left[pos].delete_at @words_left[pos].index(word1)
      else
        @words_right[pos].delete_at @words_right[pos].index(word2)
      end
    end

    save
    initwords
    true
  end

  # add new word pair
  def add(word1, word2)
    return if check(word1, word2)

    insert = false

    # try to insert as a second translation | checking left side
    @words_left.each_with_index do |words_left, i|
      if words_left.index(word1)
        @words_right[i].push word2
        insert = true
        break
      end
    end

    # try to insert as a second translation | checking right side
    # not not insert on both side
    if not insert
      @words_right.each_with_index do |words_right, i|
        if words_right.index(word2)
          @words_left[i].push word1
          insert = true
          break
        end
      end
    end

    # if it was not inserted
    if not insert
      @words_left.push [word1]
      @words_right.push [word2]
    end

    save
    initwords
  end

  # write all words to file
  def save
    return if @file.empty?
    content = []
    @words_left.each_with_index do |left, i|
      # avoid empty lines (may happen due to removal)
      next if left.count == 0 || @words_right[i] == 0
      content.push left.join(",") + "\t" + @words_right[i].join(",")
    end
    File.open(@file, "w+").write(content.join("\n"))
  end

  # find out if wordpair is in storage
  # returns nil or position
  def check(word1, word2)
    # check words on left and right hand side
    @words_left.each_with_index do |words_left,i|
      return i if words_left.index(word1) && @words_right[i].index(word2)
    end
    nil
  end

  # retrieve all items being in storage
  def get
    storage = []
    @words_left.reverse.each_with_index do |word_left,i|
      @words_right.reverse[i].each do |word_right|
        storage.push [word_left, word_right]
      end
    end
    storage
  end
end
