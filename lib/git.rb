require 'minigit'

class Git

  attr_reader :git
  attr_accessor :working_branch, :stashed_changes

  def initialize(dir)
    @git = MiniGit.new(dir)
    @stashed_changes = false
  end

  def pre_pull
    if changes_made?
      stash
      @stashed_changes = true
    end
    @working_branch = current_branch
    git.checkout 'master' unless master?
  end

  def merge_master
    git.add '.'
    is_dirty = git.commit m: '"latest from LIMS"' rescue false
    git.push if is_dirty
    post_pull
  end

  def post_pull
    git.checkout working_branch
    pop_stash if stashed_changes
  end

  def master?
    current_branch == 'master'
  end

  def changes_made?
    !git.capturing.status.include?('working tree clean')
  end

  def current_branch
    git.capturing.branch.match(/\*\s(.*)\n/)[1]
  end

  def dir
    git.git_work_tree
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
