#encoding:utf-8
class SessionsController < ApplicationController
  require 'multi_json'
  require 'uri'
  def new

  end
  def create
    require 'net/http'
    login_name = params[:session][:username]
    password = params[:session][:password]
    param = {'username' => login_name,'password' => password}
    if !login_name.nil? && !password.nil?
      path = 'sessions/login_in'
      @user = User.new
      @search_result = @user.curl(path,param)
      @torf={}
      if @search_result['success']
        cookies.permanent[:remember_token] = @search_result['data']['remember_token']
        self.current_user = @search_result['data']
        @torf={:torf => 'true'}
        respond_to do |format|
          format.html
          format.json { render json: @torf }
          format.js
        end
      else
        @torf={:torf => 'false'}
        respond_to do |format|
          format.html
          format.json { render json: @torf }
          format.js
        end
      end
    end
  end
  def destroy
    sign_out
    redirect_to root_path
  end
end