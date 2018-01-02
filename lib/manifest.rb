
class Manifest

  def initialize(dir, scripts)
    @dir = dir
    @scripts = scripts
  end

  def create
    File.open(path, 'w+') do |f|
      f.write(data)
    end
  end

  private

  attr_reader :dir, :scripts

  def data
    JSON.pretty_generate({ scripts: scripts.map(&:to_h) })
  end

  def filename
    'manifest.json'
  end

  def path
    File.join(dir, filename)
  end
end