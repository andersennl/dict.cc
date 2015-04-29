require "yaml"

module Path
  def self.set_homepath(path)
    return path.sub("homepath", "#{Dir.home}") if path =~ /homepath/
    path
  end

  def self.config
    YAML.load File.open("config.yml")
  end

  def self.dic_wb
    set_homepath(config["dictionary"]["wb"])
  end

  def self.limit
    set_homepath(config["dictionary"]["limit"])
  end

  def self.file
    set_homepath(config["storage"]["file"])
  end
end
