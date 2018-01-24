require 'listen'
require 'pry'
require_relative 'lib/config'
require_relative 'lib/git'
require_relative 'lib/manifest'
require_relative 'lib/script'
require_relative 'lib/script_uploader'

class Listener

  def run
    listener.start
  end

  private

  attr_reader :config, :manifest, :listener

  def listener
    @listener ||= Listen.to(dir, only: /.rb$/) do |modified, added, removed|
      if modified
        Thread.new(self.send(:listener)) { |l| l.pause }.join
        git = Git.new
        my_branch = git.branch_and_commit
        upload_script(my_branch)
        git.git.checkout 'master'
        git.delete_branch(my_branch)
        self.send(:listener).send(:backend).send(:adapter).send(:config).send(:queue).send(:event_queue).clear
        Thread.new(self.send(:listener)) { |l| l.start }.join
      end
    end
  end

  def dir
    config.local.output_path
  end

  def config
    @config ||= Config.data
  end

  def upload_script(branch_name)
    ScriptUploader.new(branch_name).run
  end
end

listener = Listener.new
listener.run

sleep
