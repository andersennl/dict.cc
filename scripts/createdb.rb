require "sqlite3"
require "yaml"

class CreateDB

  def initialize
    @config = YAML.load(File.open("config.yml"))

    if File.file?(@config["dictionary"]["wb"])
      puts "File #{@config["dictionary"]["wb"]} already exists. Delete it to continue."
      exit
    end

    @db = SQLite3::Database.new(@config["dictionary"]["wb"])
    @storage = []
  end

  def create_db
    @db.execute("CREATE VIRTUAL TABLE IF NOT EXISTS wb_idx USING fts4(refid INT, content TEXT)")
    @db.execute("DELETE FROM wb_idx")
  end

  def convert_line(line)
    # strip meta information
    line.gsub!(/\[.*?\]/, "")
    line.gsub!(/\{.*?\}/, "")
    line.gsub!(/\<.*?\>/, "")
    line.gsub!(/\(.*?\)/, "")

    # save quotes
    line = line.gsub(/\\/, '\&\&').gsub(/'/, "''")

    # strip last part and clean first parts
    line = line.split("\t")
    return "" if not line[0] or not line[1]
    line = line[0].strip + "\t" + line[1].strip
  end

  def run
    
    file = Dir[File.join(File.dirname(@config["dictionary"]["wb"]), "*.txt")]
    if file.count==0
      puts "No file to convert in dir: #{@config["dictionary"]["wb"]}"
      exit
    end

    create_db

    data = File.new(file.first).read.split("\n")

    data.each_with_index do |line, i|
      line.strip!
      next if not line
      next if line.empty?
      next if line[0] == "#"

      content = convert_line(line)
      next if content.empty?

      # check & put to storage to determine if we already have that word combination
      next if @storage.index(content)
      @storage.push content

      @db.execute("INSERT INTO wb_idx (refid, content) VALUES(#{i}, '#{content}') ")

      p = i / (data.count / 100)
      print "\rprocessed: #{i} of #{data.count} (#{p}%)... "

    end
  end
end

CreateDB.new.run
