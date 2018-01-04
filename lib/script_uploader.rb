require 'fileutils'
require 'minigit'
require 'pry'
require_relative 'config'
require_relative 'lims'
require_relative 'manifest'
require_relative 'script'
require_relative 'script_downloader'

class ScriptUploader

  attr_reader :branch_name

  def initialize(branch_name)
    @branch_name = branch_name
  end

  def run
    pull_lims_scripts
    upload
    pre_merge
    merge
    push
    post_merge
  end

  private

  attr_accessor :modified_scripts
  attr_reader :script_downloader, :git, :config, :output_path, :manifest, :lims

  def upload
    modified_scripts.each do |script|
      res = lims.upload_script(script)
    end
  end

  def modified_scripts
    @modified_scripts ||= git.modified_scripts(branch_name).map do |script|
      Script.new(script_metadata.find { |s| script < s }.merge(code: nil, base_path: output_path))
    end
  end

  def pre_merge
    git.pre_merge
  end

  def merge
    git.merge(branch_name)
  end

  def push
    git.push
  end

  def post_merge
    git.post_merge
  end

  def pull_lims_scripts
    script_downloader.run
  end

  def script_downloader
    @script_downloader ||= ScriptDownloader.new(skip_push = true)
  end

  def git
    @git ||= Git.new
  end

  def output_path
    @output_path ||= config.local.output_path
  end

  def config
    @config ||= Config.data
  end

  def script_metadata
    manifest.scripts[:scripts]
  end

  def manifest
    @manifest ||= Manifest.new(output_path)
  end

  def lims
    @lims ||= Lims.new
  end
end

# binding.pry
