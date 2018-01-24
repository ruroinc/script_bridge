require_relative 'lib/script_uploader'

puts 'Enter branch name'
branch_name = gets.chomp

ScriptUploader.new(branch_name).run
