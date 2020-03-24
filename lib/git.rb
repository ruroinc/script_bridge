require 'minigit'
require 'time'
require_relative 'config'

class Git

  attr_reader :git
  attr_accessor :working_branch, :need_stash, :pull_branch_name, :push_branch_name

  def initialize
    @stashed_changes = false
  end

  def pre
    stash if need_stash
    @working_branch = current_branch
  end

  def post
    git.checkout working_branch
    pop_stash if need_stash
  end

  def pre_pull
    pre
    git.checkout 'master'
    git.checkout({ b: true }, pull_branch_name)
  end

  def pull
    git.add '.'
    git.commit m: pull_commit_message rescue false
    git.checkout 'master'
    git.pull
    git.merge pull_branch_name
  end

  def push
    git.push
  end

  def post_pull
    post
    delete_branch(pull_branch_name)
  end

  def pre_merge
    pre
  end

  def post_merge
    post
  end

  def merge(branch)
    git.checkout 'master'
    git.pull
    git.merge branch
  end

  def branch_and_commit
    @working_branch = current_branch
    git.checkout 'master'
    git.checkout({ b: true }, push_branch_name)
    git.add '.'
    git.commit m: push_commit_message rescue false
    push_branch_name
  end

  def delete_branch(branch)
    git.branch({ D: true }, branch)
  end

  def need_stash
    @need_stash ||= !git.capturing.status.include?('working tree clean')
  end

  def modified_scripts(branch)
    args = ['diff', { 'name-only' => true }]
    args << "master..#{branch}" unless branch == 'master'
    git.capturing.git(*args).scan(/(.+)(?=.rb)/).flat_map do |f|
      [:human_type, :human_field, :name].zip(f.first.split('/')[-3..-1]).to_h
    end
  end

  def current_branch
    git.capturing.branch.match(/\*\s(.*)\n/)[1]
  end

  def dir
    config.local.output_path.tap do |d|
      FileUtils.mkdir_p(d) unless File.exist?(d)
    end
  end

  def user
    config.lims.username
  end

  def config
    @config ||= Config.data
  end

  def git
    @git = MiniGit.new(dir)
  end

  def pull_commit_message
    "latest from LIMS #{Time.now.getutc.iso8601}"
  end

  def push_commit_message
    "#{user} #{Time.now.getutc.iso8601}"
  end

  def pull_branch_name
    @pull_branch_name ||= "#{Time.now.getutc.iso8601.tr(':', '-')}-latest-from-LIMS"
  end

  def push_branch_name
    @push_branch_name ||= "#{Time.now.getutc.iso8601.tr(':', '-')}-#{user}"
  end

  def stash
    Dir.chdir(dir) do
      system(git.git_command, 'stash')
    end
  end

  def pop_stash
    Dir.chdir(dir) do
      system(git.git_command, 'stash', 'pop')
    end
  end
end
