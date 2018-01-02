require 'active_support/core_ext/hash'
require 'json'
require 'ostruct'
require 'yaml'

class Config

  attr_reader :data

  def self.data
    @data ||= JSON.parse(json_data, object_class: OpenStruct)
  end

  private

  def self.file_name
    'application.yml'
  end

  def self.path
    Pathname.new(__dir__).join("../config/#{file_name}")
  end

  def self.raw_data
    File.open(path).read
  end

  def self.json_data
    YAML.safe_load(raw_data).to_json
  end
end
