require_relative 'config'
require 'mechanize'
require 'pry'

class Lims

  def scripts
    signin unless signed_in?
    all_scripts = []
    while all_scripts.size != num_scripts
      res = JSON.parse(mech.get(scripts_url, start: all_scripts.size).body)
      @num_scripts = res['Total'] unless num_scripts
      all_scripts.concat(res['Scripts'])
    end
    all_scripts
  end

  def upload_script(script)
    signin unless signed_in?
    mech.post(save_script_url, script_params(script))
  end

  private

  attr_accessor :num_scripts, :token
  attr_reader :config, :mech

  def mech
    @mech ||= Mechanize.new.tap do |m|
      m.user_agent_alias = 'Mac Safari'
    end
  end

  def token_pattern
    /conn.extraParams\['authenticity_token'\] = '(.*)'/
  end

  def extra_token_pattern
    /extraToken: '(.*)'/
  end

  def signin_token
    @token = signin_page.match(token_pattern)[1]
  end

  def extra_token
    @token = root_page.match(extra_token_pattern)[1]
  end

  def signed_in?
    mech.cookies.any? { |cookie| cookie.name == 'lims_session_id' }
  end

  def signin_page
    mech.get(signin_url).body
  end

  def signin
    mech.post(signin_url, auth_params)
  end

  def root_page
    mech.get(root_url, authenticity_token: token).body
  end

  def auth_params
    {
      username: config.lims.username,
      password: config.lims.password,
      authenticity_token: signin_token,
      close_other_session: 'true'
    }
  end

  def script_params(script)
    {
      obj_id: script.id,
      obj_type: script.type,
      field: script.field,
      script: script.code,
      authenticity_token: extra_token
    }
  end

  def root_url
    config.lims.host
  end

  def signin_url
    "#{root_url}/signin"
  end

  def scripts_url
    "#{root_url}/admin/view_scripts_list"
  end

  def save_script_url
    "#{root_url}/admin/save_script_code"
  end

  def config
    @config ||= Config.data
  end
end
