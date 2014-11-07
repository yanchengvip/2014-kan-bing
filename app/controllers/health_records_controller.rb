#encoding:utf-8
class HealthRecordsController < ApplicationController
  require 'open-uri'
  delegate "default_access_url_prefix_with", :to => "ActionController::Base.helpers"
  before_filter :signed_in_user
  skip_before_filter :verify_authenticity_token ,only:[:upload]
  #before_filter :user_health_record_power, only: [:ct,:ultrasound,:inspection_report]
  def play_video
    url = params[:video_url].split('.')[0]
    @video_url = Settings.edu_video + url[1,2] + '/' + url[4,2] + '/' + url[7,2] + '/' + url[10,30]
  end

  def go_where
    case params[:child_type]
      when 'CT'
        redirect_to '/health_records/ct?uuid='+params[:uuid]
      when '超声'
        redirect_to '/health_records/ultrasound?uuid='+params[:uuid]
      when '检验报告'
        redirect_to '/health_records/inspection_report?uuid='+params[:uuid]
      when '核磁'
        redirect_to '/health_records/mri?uuid='+params[:uuid]
      when '心电图'
        redirect_to '/ecg/show?ecg_id='+params[:uuid]
    end
  end

  def ct
    @obj ||= params[:uuid]
  end

  # 核磁
  def mri
    @obj ||= params[:uuid]
  end


  def ultrasound
    @uuid = params[:uuid]
    Aliyun::OSS::Base.establish_connection!(
        :server => 'oss.aliyuncs.com', #可不填,默认为此项
        :access_key_id => 'h17xgVZatOgQ6IeJ',
        :secret_access_key => '6RrQAXRaurcitBPzdQ18nrvEWjWuWO'
    )
    @flag = OSSObject.exists?(@uuid, 'mimas-open') #defaultbucket
    testmsg = ""
    xmlfile = replacewithsubfix(@uuid,"xml")
    pdffile = replacewithsubfix(@uuid,"pdf")

    #根据uuid 获取xml pdf
    #返回reportimage   Imagelist  videolist
    #if flag
    #
    #  xmlfile = "http://fit-ark.xicp.net:7500/files/109473c0c2a04c909f838fd6b71ddc96.xml"
    #  doc = Nokogiri::XML(open(xmlfile))
    #  st  =doc.xpath("//ImageList/de ")
    #  ar =st.attr('value').to_s
    #  @imagelist = ar.split(",")
    #else
    #end

    uuid = @uuid.split('.')[0]
    @uuid = uuid+'.png'
    @pic = []
    is_more = true
    num = 1
    @uuidObj = Uuid.new
    while is_more
      file_path = Settings.files_mount + 'png/' + @uuidObj.parse_uuid(uuid)+"_#{num}.png"
      if File.exist?(file_path)
        @pic << uuid+"_#{num}.png"
        num+=1
      else
        is_more = false
      end
    end
    @pics = @pic.join(',')
  end

  def inspection_report
    @uuid = params[:uuid]
    @uuid = @uuid.split('.')[0]+'.png'
  end

  def get_video
    send_data data.read, type: "application/x-shockwave-flash", disposition: "inline", stream: "true"
  end




  def get_data
    patient_id = session["patient_id"]
    irs = InspectionReport.where("patient_id = ?", patient_id).length
    cts = InspectionCt.where("patient_id = ?", patient_id).length
    ults = InspectionUltrasound.where("patient_id = ?", patient_id).length
    nms = InspectionNuclearMagnetic.where("patient_id = ?", patient_id).length
    inds = InspectionData.where("patient_id = ?", patient_id).length
    data = {
        "ct" => cts,
        "ult" => ults,
        "nm" => nms,
        "dicom" => cts+ults+nms,
        "ins_report" => inds,
        "ins" => inds,
        "all" => irs
    }
    render json: {data: data}
  end

  def dicom
    @irs = InspectionReport.
        where("patient_id = ?", session["patient_id"]).
        paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
    render partial: 'health_records/dicom'
  end

  def inspection
    @irs = InspectionReport.
        where("patient_id = ? and (child_type = ? or child_type = ? or child_type = ?)",session["patient_id"],'CT','超声','核磁',).
        paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
    render partial: 'health_records/dicom'
  end

  def ct2
    #@irs = InspectionReport.
    #    where("patient_id = ? and child_type = ? ",session["patient_id"],'CT').
    #    paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
    @irs = InspectionCt.
        where("patient_id = ?",session["patient_id"]).
        paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
    render partial: 'health_records/ct'
  end
   def mri2
     #@irs = InspectionReport.
     #    where("patient_id = ? and child_type = ? ",session["patient_id"],'核磁').
     #    paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
     @irs = InspectionNuclearMagnetic.
         where("patient_id = ?",session["patient_id"]).
         paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
     render partial: 'health_records/mri'
   end

  def ultrasound2
    #@irs = InspectionReport.
    #    where("patient_id = ? and child_type = ? ",session["patient_id"],'超声').
    #    paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
    @irs = InspectionUltrasound.
        where("patient_id = ?",session["patient_id"]).
        paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
    render partial: 'health_records/ultrasound'
  end

  def inspection_report2
    #@irs = InspectionReport.
    #    where("patient_id = ? and child_type = ? ",session["patient_id"],'检验报告').
    #    paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
    @irs = InspectionData.
        where("patient_id = ?",session["patient_id"]).
        paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
    render partial: 'health_records/inspection_report'
  end

  def undefined_other
    render partial: 'health_records/undefined_other'
  end

  def upload
    target_dir = Rails.root.join('public', 'uploads/cts')
    Dir.mkdir(target_dir) unless File.exists?(target_dir)
    #后面为false 前面会执行
    if !params[:fileToUpload].nil?

      uploaded_io = params[:fileToUpload]
      filename = uploaded_io.original_filename
      begin
        File.open(Rails.root.join('public', 'uploads/cts', filename), 'wb') do |file|
          file.write(uploaded_io.read)
        end
      rescue StandardError => e
        puts e
      ensure
        tempfile = uploaded_io.tempfile.path
        if File.exists?(tempfile)
          File.delete(tempfile)
        end
      end

    end

    if true
      render :text => ({:error => "upload successs", data: true}.to_json)
    else
      render :text => ({:error => "upload fail", data: false}.to_json)
    end

  end

  private
  #判断有无权限读取某一患者的超声报告
  def user_health_record_power
    @ips = InspectionReport.where('thumbnail=?',params[:uuid])
    is_equal = false
    unless @ips.empty?
      @ip = @ips.first
      if !current_user.patient_id.nil?
        is_equal = true if current_user.patient_id == @ip.patient_id
      else !current_user.doctor_id.nil?
        is_equal = true if (!Patient.where('id=? and doctor_id=?',@ip.patient_id,current_user.doctor_id).empty? || !TreatmentRelationship.where('doctor_id=? and patient_id=?',current_user.doctor_id,@ip.patient_id).empty?)
      end
    end
    redirect_to '/' unless is_equal
  end
end
