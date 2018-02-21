require 'pry'
require_relative 'lib/config'
require_relative 'lib/git'
require_relative 'lib/manifest'
require_relative 'lib/script'
require_relative 'lib/script_uploader'

class GitPush

  def run
    git = Git.new
    my_branch = git.branch_and_commit
    git.pre_merge
    git.merge(my_branch)
    git.push
    git.post_merge
    git.git.checkout 'master'
    git.delete_branch(my_branch)
  end

  private

  attr_reader :config

  def dir
    config.local.output_path
  end

  def config
    @config ||= Config.data
  end
end

pusher = GitPush.new
pusher.run
puts "Pushed to git!"
