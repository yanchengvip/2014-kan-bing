#encoding:utf-8
class HealthRecordsController < ApplicationController
  before_filter :signed_in_user
  before_filter :user_health_record_power, only: [:ct,:ultrasound,:inspection_report]
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
    end
  end

  def ct
    @obj ||= params[:uuid]
  end

  def ultrasound
    @uuid = params[:uuid]
    @uuid = @uuid.split('.')[0]+'.png'
  end

  def inspection_report
    @uuid = params[:uuid]
    @uuid = @uuid.split('.')[0]+'.png'
  end

  def get_video
    send_data data.read, type: "application/x-shockwave-flash", disposition: "inline", stream: "true"
  end




  def get_data
    @irs = InspectionReport.where("patient_id = ?", session["patient_id"])
    ct = 0
    ult = 0
    ins_report = 0
    @irs.each do |i|
      case i.child_type
        when 'CT'
          ct += 1
          next
        when '超声'
          ult += 1
          next
        when '检验报告'
          ins_report += 1
          next
      end
    end
    dicom = ct + ult
    ins = ins_report
    data = {
        "ct" => ct,
        "ult" => ult,
        "dicom" => dicom,
        "ins_report" => ins_report,
        "ins" => ins,
        "all" => dicom+ins
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
        where("patient_id = ? and (child_type = ? or child_type = ?)",session["patient_id"],'CT','超声').
        paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
    render partial: 'health_records/dicom'
  end

  def ct2
    @irs = InspectionReport.
        where("patient_id = ? and child_type = ? ",session["patient_id"],'CT').
        paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
    render partial: 'health_records/ct'
  end

  def ultrasound2
    @irs = InspectionReport.
        where("patient_id = ? and child_type = ? ",session["patient_id"],'超声').
        paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
    render partial: 'health_records/ultrasound'
  end

  def inspection_report2
    @irs = InspectionReport.
        where("patient_id = ? and child_type = ? ",session["patient_id"],'检验报告').
        paginate(:per_page => 20, :page => params[:page], :order => 'checked_at DESC')
    render partial: 'health_records/inspection_report'
  end

  def undefined_other
    render partial: 'health_records/undefined_other'
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
        @doc = Patient.find_by_id(@ip.patient_id).doctor
        is_equal = true if !(@doctor=Doctor.find_by_id(current_user.doctor_id)).nil? && @doc==@doctor
      end
      redirect_to '/' unless is_equal
    end
  end

end
