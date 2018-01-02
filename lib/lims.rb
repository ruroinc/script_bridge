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
    mech.post(save_script_url, script_params(script))
  end

  private

  attr_accessor :num_scripts
  attr_reader :config, :mech

  def mech
    @mech ||= Mechanize.new.tap do |m|
      m.user_agent_alias = 'Mac Safari'
    end
  end

  def token_pattern
    /conn.extraParams\['authenticity_token'\] = '(.*)'/
  end

  def signin_token
    signin_page.match(token_pattern)[1]
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
      id: script.id,
      script: {
        name: script.name,
        code: script.code
      },
      authenticity_token: 'temp'
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
    "#{root_url}/admin/save_script"
  end

  def config
    @config ||= Config.data
  end
end
