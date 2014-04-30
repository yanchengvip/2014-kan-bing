#encoding:utf-8
class UsersController < ApplicationController
  before_filter :signed_in_user,except:[:username_verification]
  def index
  end
  def show
  end

  def new
  end
  def setting
    @image = '/code/code_image'
    @user = nil
    @photo=''
    if !current_user.doctor_id.nil?
      @user = Doctor.find(current_user.doctor_id)
    elsif !current_user.patient_id.nil?
      @user = Patient.find(current_user.patient_id)
    end
    if !@user.photo.nil? && @user.photo!=''
      @photo = Settings.pic+@user.photo
    end

  end
  def code_refresh
    @image = '/code/code_image'
    render json: {image: @image}
  end

  def profile_update
    user=params['@user']
    username=user['username']
    name=user['name']
    email=user['email']
    mobile_phone=user['mobile_phone']
    language=user['language']
    birthday=user['birthday']
    gender=user['gender']
    address=user['address']
    current_user.update_attributes(name:username,email:email,mobile_phone:mobile_phone)
    if !current_user.doctor_id.nil?
      expertise=user['expertise']
      introduction=user['introduction']
      current_user.doctor.update_attributes(name:name,email:email,mobile_phone:mobile_phone,birthday:birthday,gender:gender,address:address,expertise:expertise,introduction:introduction)
    else
      current_user.patient.update_attributes(name:name,email:email,mobile_phone:mobile_phone,birthday:birthday,gender:gender,address:address)
    end

    @image = '/code/code_image'
    @user = nil
    @photo=''
    if !current_user.doctor_id.nil?
      @user = Doctor.find(current_user.doctor_id)
    elsif !current_user.patient_id.nil?
      @user = Patient.find(current_user.patient_id)
    end
    if !@user.photo.nil? && @user.photo!=''
      @photo = Settings.pic+@user.photo
    end
    render partial: 'users/setting_profile'
    #@email=params[
    #    format.json  {render json: @js }
    #    format.js
    #  end
    #elsif @exist==false
    #  @js={:pd => 'exist_false'}
    #  respond_to do |format|
    #    format.html
    #    format.json  {render json: @js }
    #    format.js
    #  end
    #elsif @email.nil?
    #  @js={:pd => 'email_false'}
    #  respond_to do |format|
    #    format.html
    #    format.json  {render json: @js }
    #    format.js
    #  end
    #else
    #  if !params[:@user][:username].nil?
    #    current_user.update_attribute(:name, params[:@user][:username])
    #  end
    #  if !current_user.doctor_id.nil? && current_user.doctor_id != ''
    #    @doctor = Doctor.find(current_user.doctor_id)
    #    @doctor.update_attributes(name: params[:@user][:realname],address: params[:@user][:address],mobile_phone:params[:@user][:phone],email:params[:@user][:email],birthday:params[:@user][:birthday],gender:params[:@user][:gender],introduction: params[:@user][:introduction])
    #  elsif !current_user.patient_id.nil? && current_user.patient_id != ''
    #    @patient = Patient.find(current_user.patient_id)
    #    @patient.update_attributes(name: params[:@user][:realname],address: params[:@user][:address],mobile_phone:params[:@user][:phone],email:params[:@user][:email],birthday:params[:@user][:birthday],gender:params[:@user][:gender],introduction: params[:@user][:introduction])
    #  end
    #  @js={:pd => 'true'}
    #  respond_to do |format|
    #    format.html
    #    format.json  {render json: @js }
    #    format.js
    #  end
    #end
  end



  def password_update
    #puts session[:code]
    #@js={}
    #if params[:@user][:new_password] != params[:@user][:password_confirmation] || params[:@user][:new_password].length<6
    #  @js={:pd => 'new_false'}
    #elsif params[:@user][:code]!=session[:code]
    #  @js={:pd => 'code_false'}
    #  respond_to do |format|
    #    format.html
    #    format.json  {render :json => @js}
    #    format.js
    #  end
    #else
    #  if current_user.authenticate(params[:@user][:old_password]) == false
    #    @js={:pd=>'old_false'}
    #    respond_to do |format|
    #      format.html
    #      format.json  {render json: @js }
    #      format.js
    #    end
    #  else
        current_user.update_attribute(:password, params[:@user][:new_password])
        sign_in current_user
    #    @js={:pd=>'true'}
    #    respond_to do |format|
    #      format.html
    #      format.json  {render json: @js }
    #      format.js
    #    end
    #  end
    #end
    #puts 'baekhyun'
    #puts @js[:pd]
    flash[:success]='密码修改成功！'
    redirect_to root_path
  end

  def find_by_name
    @user = User.new
    @doctors = Doctor.find_by_name(params[:@user][:name])
    if @doctors.length == 1
      redirect_to '/doctors/doctorpage/' + @doctors.first.id.to_s
    else
      @doctor_users = @doctors.paginate(:per_page =>8,:page => params[:page])
      render :template => 'users/search_doctors'
    end
  end


  #院内同步时，验证用户名是否已存在
  def username_verification
    username=params[:username]
    @user=User.find_by_name(username)
    if @user
      render json:{success:false,content:'此用户名已存在'}
    else

      render json:{success:true,content:'此用户名可以使用'}
    end

  end

  #修改个人信息用户名验证
  def check_username
    username=params[:username]
    @user=User.find_by_name(username)
    if @user&&current_user.name!=username
      render json:{success:false,content:'此用户名已存在'}
    else
      render json:{success:true,content:'此用户名可以使用'}
    end
  end
  def check_email
    email=params[:email]
    @user=User.where('email=?',email)

    if @user && current_user.email!=email
      render json:{success:false,content:'此邮箱已注册'}
    else
      render json:{success:true,content:'此邮箱可以使用'}
    end
  end
  def check_phone
    mobile_phone=params[:phone]
    @user=User.where('email=?',mobile_phone)

    if @user && current_user.mobile_phone!=mobile_phone
      render json:{success:false,content:'此电话已占用'}
    else
      render json:{success:true,content:'电话可以使用'}
    end
  end

  def check_old_pwd
     if current_user.authenticate(params[:old_password])
       render json:{success:true,content:'原密码正确！'}
     else
       render json:{success:false,content:'原密码错误！'}
     end
  end

  def check_code
    if params[:code]==session[:code]
      render json:{success:true,content:' 验证码正确！'}
    else
      render json:{success:false,content:'验证码错误！'}
    end
  end
  private
  def user_params
    params.require(:user).permit(:id, :username,:card_number,:email, :password, :password_confirmation, :patient_id, :doctor_id,:is_doctor, :is_health_admin)
  end
end
