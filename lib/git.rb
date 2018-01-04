require 'minigit'
require 'time'

class Git

  attr_reader :git
  attr_accessor :working_branch, :need_stash, :new_branch_name

  def initialize(dir)
    @git = MiniGit.new(dir)
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
    git.checkout({ b: true }, new_branch_name)
  end

  def pull
    git.add '.'
    git.commit m: pull_commit_message rescue false
    git.checkout 'master'
    git.pull
    git.merge new_branch_name
  end

  def push
    git.push
  end

  def post_pull
    post
    git.branch({ D: true }, new_branch_name)
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

  def need_stash
    @need_stash ||= !git.capturing.status.include?('working tree clean')
  end

  def scripts_changed(branch)
    git.capturing.git('diff', { 'name-only' => true }, "master..#{branch}").scan(/(.+)(?=.rb)/).flat_map do |f|
      [:human_type, :human_field, :name].zip(f.first.split('/')).to_h
    end
  end

  def current_branch
    git.capturing.branch.match(/\*\s(.*)\n/)[1]
  end

  def dir
    git.git_work_tree
  end

  def pull_commit_message
    "latest from LIMS #{Time.now.getutc.iso8601}"
  end

  def new_branch_name
    @new_branch_name ||= "#{Time.now.getutc.iso8601}-latest-from-LIMS".gsub(':', '-')
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
