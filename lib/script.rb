class Script

  attr_reader :id, :name, :save_name, :type, :human_type, :field, :human_field, :code, :base_path

  def initialize(id:, name:, type:, human_type:, field:, human_field:, code:, base_path:)
    @id = id
    @name = name
    @save_name = name.tr('/', "\u2215")
    @type = type
    @human_type = human_type
    @field = field
    @human_field = human_field
    @code = code
    @base_path = base_path
  end

  def code
    @code ||= File.read(path)
  end

  def filename
    "#{save_name}.rb"
  end

  def dir
    File.join(base_path, human_type, human_field)
  end

  def path
    create_dir(dir)
    File.join(dir, filename)
  end

  def create_dir(path)
    FileUtils.mkdir_p(path) unless File.exist?(path)
  end

  def tool?
    type == 'Tool'
  end

  def to_h
    {
      id: id,
      name: name,
      type: type,
      human_type: human_type,
      field: field,
      human_field: human_field
    }
  end
end
