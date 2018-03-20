require 'listen'
require 'pry'
require 'time'
require_relative 'lib/config'
require_relative 'lib/git'
require_relative 'lib/manifest'
require_relative 'lib/script'
require_relative 'lib/script_uploader'

class LisListener

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
        upload_script(git.current_branch)
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
    ScriptUploader.new(branch_name).send(:upload)
    puts "#{Time.now}: Scripts uploaded!"
  end
end

listener = LisListener.new
listener.run

sleep
