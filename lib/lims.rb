require_relative 'config'
require 'mechanize'
require 'pry'

class Lims

  def scripts
    signin unless signed_in?
    [].tap do |all_scripts|
      while all_scripts.size != num_scripts
        res = JSON.parse(mech.get(scripts_url, start: all_scripts.size, code: true).body)
        @num_scripts = res['Total'] unless num_scripts
        all_scripts.concat(res['Scripts'])
      end
    end
  end

  def upload_script(script)
    signin unless signed_in?
    mech.post(save_script_url(script), script_params(script))
  end

  private

  attr_accessor :num_scripts, :token, :version
  attr_reader :config, :mech

  def mech
    @mech ||= Mechanize.new.tap do |m|
      m.user_agent_alias = 'Mac Safari'
      m.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end

  def version_pattern
    /productVersion = '(.*?)'/
  end

  def token_pattern
    if version < 7
      /conn.extraParams\['authenticity_token'\] = '(.*?)'/
    else
      /o.params.authenticity_token = '(.*?)'/
    end
  end

  def extra_token_pattern
    if version < 7
      /extraToken: '(.*?)'/
    else
      /"extraToken":"(.*?)"/
    end
  end

  def version
    @version ||= signin_page.match(version_pattern)[1].to_f
  end

  def signin_token
    @token ||= signin_page.match(token_pattern)[1]
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
    res = JSON.parse(mech.post(signin_url, auth_params).body, symbolize_names: true)
    return if res[:success]
    mech.post(clear_session_url, auth_params.merge(stoken: res[:stoken])).body if version > 7
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
    if script.tool?
      {
        id: script.id,
        authenticity_token: extra_token,
        attrs: { script.field => script.code }
      }
    else
      {
        obj_id: script.id,
        obj_type: script.type,
        field: script.field,
        script: script.code,
        authenticity_token: extra_token
      }
    end
  end

  def root_url
    config.lims.host
  end

  def signin_url
    "#{root_url}/signin"
  end

  def clear_session_url
    "#{root_url}/session/clear"
  end

  def scripts_url
    "#{root_url}/admin/view_scripts_list"
  end

  def save_script_url(script)
    if script.tool? && version > 7
      "#{root_url}/flow/save_tool"
    else
      "#{root_url}/admin/save_script_code"
    end
  end

  def config
    @config ||= Config.data
  end
end
