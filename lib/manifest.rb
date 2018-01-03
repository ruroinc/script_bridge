
class Manifest

  attr_accessor :scripts

  def initialize(dir, scripts = nil)
    @dir = dir
    @scripts = scripts.try { |s| s.map(&:to_h) }
  end

  def create
    File.open(path, 'w+') do |f|
      f.write(data)
    end
  end

  def scripts
    @scripts ||= JSON.parse(File.read(path), symbolize_names: true)
  end

  private

  attr_reader :dir

  def data
    JSON.pretty_generate({ scripts: scripts })
  end

  def filename
    'manifest.json'
  end

  def path
    File.join(dir, filename)
  end
end