require 'fileutils'
require 'pry'
require_relative 'config'
require_relative 'git'
require_relative 'lims'
require_relative 'manifest'
require_relative 'script'

class ScriptDownloader

  def initialize(skip_push = false)
    @skip_push = skip_push
  end

  def run
    pre_pull
    save_scripts
    create_manifest
    pull
    push unless skip_push
    post_pull
  end

  private

  attr_reader :lims, :scripts, :config, :output_path, :manifest, :git, :skip_push

  def save_scripts
    scripts.each do |script|
      File.open(script.path, 'w+') do |f|
        f.write(script.code)
      end
    end
  end

  def pre_pull
    git.pre_pull
  end

  def pull
    git.pull
  end

  def push
    git.push
  end

  def post_pull
    git.post_pull
  end

  def create_manifest
    manifest.create
  end

  def scripts
    @scripts ||= lims.scripts.map do |script|
      Script.new(
        id: script['obj_id'],
        name: script['name'],
        type: script['obj_type'],
        human_type: script['hum_obj_type'],
        field: script['field'],
        human_field: script['hum_field'],
        code: script['code'],
        base_path: output_path
      )
    end
  end

  def lims
    @lims ||= Lims.new
  end

  def git
    @git ||= Git.new(output_path)
  end

  def manifest
    @manifest ||= Manifest.new(output_path, scripts)
  end

  def output_path
    @output_path ||= config.local.output_path
  end

  def config
    @config ||= Config.data
  end
end

binding.pry
