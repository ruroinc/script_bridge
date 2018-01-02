
class Script

  attr_reader :id, :name, :save_name, :type, :field, :code, :base_path

  def initialize(id:, name:, type:, field:, code:, base_path:)
    @id = id
    @name = name
    @save_name = name.gsub('/', "\u2215")
    @type = type
    @field = field
    @code = code
    @base_path = base_path
  end

  def filename
    "#{save_name}.rb"
  end

  def dir
    File.join(base_path, type, field)
  end

  def path
    create_dir(dir)
    File.join(dir, filename)
  end

  def create_dir(path)
    FileUtils::mkdir_p(path) unless File.exists?(path)
  end

  def to_h
    {
      id: id,
      name: name,
      type: type,
      field: field
    }
  end
end
