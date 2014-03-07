#encoding:utf-8
require 'will_paginate/array'
class DoctorsController < ApplicationController
  before_filter :signed_in_user, only: [:get_aspects, :doctor_page, :friends, :doctor_appointment]
  layout 'mapp', only: [:index_doctor_page]
  #首页面医生显示
  def index_doctors_list
    @doctors_all = Doctor.all
    @doctor = @doctors_all.first
    render partial: 'doctors/index_doctors_list'
  end

  #用户未登陆前察看医生主页
  def index_doctor_page
    @doctor=Doctor.find_by_id(params[:id])

    render 'doctors/index_doctor_page'
  end

  def doctor_page
    #if params[:id].to_i == current_user['doctor_id'].to_i
    #  redirect_to '/home'
    #end
    flag = false
    if !current_user.doctor_id.nil?
      flag = DoctorFriendship.is_friends(current_user.doctor_id, params[:id])
    elsif !current_user.patient_id.nil?
      flag = TreatmentRelationship.is_friends(params[:id], current_user.patient_id)
    end
    @doctor1 = Doctor.find(params[:id])
    @doctor_id = params[:id]
    @is_friends = flag
  end


  #医生人际关系列表 type值=>1:患者管理,2:我的同行
  def show_friends
    @doctor = current_user.doctor
    type=params[:type].to_i
    if type==1
      render template: 'doctors/doctor_patients'
    else
      @friends = Array.new
      @dfs1 = DoctorFriendship.where(doctor1_id: @doctor.id)
      for df1 in @dfs1
        doc1=Doctor.find(df1.doctor2_id)
        @friends.push(doc1)
      end
      @dfs2 = DoctorFriendship.where(doctor2_id: @doctor.id)
      for df2 in @dfs2
        doc2=Doctor.find(df2.doctor1_id)
        @friends.push(doc2)
      end
      @cont_doctors = @friends
      @contact_doctors = @cont_doctors.paginate(:per_page => 6, :page => params[:page])
      render template: 'doctors/doctor_friends'
    end
  end

  def get_main_patients
    @doctor = current_user.doctor
    @cont_main_users = @doctor.patients
    @contact_main_users = @cont_main_users.paginate(:per_page => 18, :page => params[:page])
    render partial: 'doctors/main_user'
  end

  def get_fri_patients
    @doctor = current_user.doctor
    @cont_users = @doctor.patfriends
    @contact_users = @cont_users.paginate(:per_page => 18, :page => params[:page])
    render partial: 'doctors/fri_user'
  end
end
