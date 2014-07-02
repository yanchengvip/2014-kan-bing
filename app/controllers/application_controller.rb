#encoding:utf-8
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  def checksignedin
    if app_checksignedin
      return true
    else
      render json:{success:false,data:' 你尚未登录，请登录后再进行操作！'}
      return false
    end
  end
  weixin = Settings.weixin
  WEIXINOAUTH = weixin.oauth + 'appid=' +weixin.app_id + '&redirect_uri=' + Rack::Utils.escape(Settings.weixin.redirect_uri) + '&response_type=code&scope=snsapi_base&state=123#wechat_redirect'
end
