Mimas::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  #root 'welcome#index'

  root 'home#index'
  get '/home', to: 'home#home'
  mount Dione::Engine, :at => '/dione'
  mount Jsdicom::Engine, :at => '/dicom'
  resources :sessions do
    collection do
      #match '/signin',  to: 'sessions#new',         via: 'get'
      match '/signout', to: 'sessions#destroy', via: 'delete'
      post '/login_public',to: 'sessions#login_interface'    #gremed接口
      #match 'checksignedin_app', to: 'sessions#check_signed_in_app', via: [:get, :post]#移动端接口,检查是否当前登录用户
      #post '/app_login',to: 'sessions#login_app'    #移动端接口,登录
      #post 'app_sign_up', to:'sessions#sign_up_app' #移动端接口,注册
    end
  end
  resources :app_sessions do
    collection do
      post '/app_login',to: 'app_sessions#login_app'    #移动端接口,登录
      match 'app_checksignedin', to: 'app_sessions#check_signed_in_app', via: [:get, :post]  #移动端接口,检查是否当前登录用户
      post 'app_sign_up', to:'app_sessions#sign_up_app'  #移动端接口,注册
    end
  end

  resource :app_admin_replies do
    collection do
      post 'app_create_reply', to: 'app_admin_replies#create_reply_app'
    end
  end

  resource :app_user_feedbacks do
    collection do
      get 'app_show_all', to: 'app_user_feedbacks#show_all_app'
      post 'app_create_feedback', to: 'app_user_feedbacks#create_feedback_app'
      get 'app_get_feedback', to: 'app_user_feedbacks#get_feedback_app'
    end
  end

  resource :home do
    collection do
      get '/about', to: 'home#about'
      get '/contact', to: 'home#contact'

    end
  end
  resource :code do
    collection do
      get '/code_image' => 'code#code_image'
    end
  end
  resources :users do
    collection do
      get '/signup', to: 'users#new'
      get '/setting' => 'users#setting'
      get '/code_refresh' => 'users#code_refresh'
      post '/profile_update' => 'users#profile_update'
      post '/password_update' => 'users#password_update'
      get '/find_by_name' => 'users#find_by_name'
      post '/find_by_name3' => 'users#find_by_name3'
      get  '/username_verification',to:'users#username_verification'
      get '/check_username',to:'users#check_username'
      get '/check_email' ,to:'users#check_email'
      get '/check_phone',to:'users#check_phone'
      get '/check_old_pwd', to:'users#check_old_pwd'
      get '/check_code', to:'users#check_code'
      post 'register_user',to:'users#register_user'
      #post 'sign_up', to:'users#sign_up'
      #get 'app_get_user', to:'users#get_user_app'
      #post 'app_profile_update', to: 'users#profile_update_app'
      #post 'app_password_update', to:'users#password_update_app'
    end
  end

  resource :app_users do
    collection do
      get 'app_get_user', to:'app_users#get_user_app'  #移动端接口,获取个人信息
      post 'app_profile_update', to: 'app_users#profile_update_app' #移动端接口,修改个人信息
      post 'app_password_update', to:'app_users#password_update_app'  #移动端接口,修改密码
    end
  end

  resources :mailers do
    collection do
      get '/to_retrieve_pwd_page', to:'mailers#to_retrieve_pwd_page'
      post '/pwd_email', to:'mailers#find_password'
      get '/go_to_show_message', to: 'mailers#go_to_show_message'
      get '/update_pwd_page/:md5id', to:'mailers#update_pwd_page'
      post '/reset_pwd', to:'mailers#reset_pwd'
      get '/code_refresh', to:'mailers#code_refresh'
    end
  end

  resource :doctors do
    collection do
      get '/get_main_patients', to: 'doctors#get_main_patients'
      get '/get_fri_patients', to: 'doctors#get_fri_patients'
      get '/get_patient_aspects', to: 'doctors#get_patient_aspects'
      get '/index_doctors_list', to: 'doctors#index_doctors_list'
      get '/get_aspects', to: 'doctors#get_aspects'
      match '/doctorpage/:id', to: 'doctors#doctor_page', via: [:get, :delete]
      get '/doc_aspects', to: 'doctors#doc_aspects'
      get '/doctorfriends', to: 'doctors#friends'
      get  '/show_friends',to:'doctors#show_friends'
      get '/doctor_appointment/:id', to: 'doctors#doctor_appointment'
      get '/show_doctor',to:'doctors#index_doctor_page'
      get '/get_patients', to:'doctors#get_patients'
      get  '/play_video',to:'doctors#play_video'

    end
  end
  resource :navigations do
    collection do
      post 'signed_mini'
      get '/navigationhealthrecord' => 'navigations#navigation_health_record'
      get '/navigationconsultation' => 'navigations#remote_consultation'
    end
  end
  resource :appointments do
    collection do
      get 'find_by_id', to: 'appointments#find_by_id'
      post '/create', to: 'appointments#create'
      match '/myappointment', to: 'appointments#myappointment', :via => [:post, :get]
      get '/get_department', to: 'appointments#get_dept'
      post '/tagabsence', to: 'appointments#tagabsence' #标记取消
      post '/tagcancel', to: 'appointments#tagcancel'
      post '/tagcomplete', to: 'appointments#tagcomplete'
      delete '/delUser', to: 'appointments#delUser'
      match '/get_doctors', to: 'appointments#get_doctors', :via => [:post, :get]

    end
  end

  resources :appointment_schedules do
    collection do
      match '/create', to: 'appointment_schedules#create',:via => [:get,:post]
      get '/destroy/:id' , to: 'appointment_schedules#destroy'
      get '/doctorschedule', to: 'appointment_schedules#doctorschedule'
      get '/doctorschedule2', to: 'appointment_schedules#doctorschedule2'
      get '/doc_schedule', to:'appointment_schedules#doc_schedule'
      #get '/cancelthisweekschedule', to: 'appointment_schedules#cancelthisweekschedule'
      match '/updateschedule', to: 'appointment_schedules#updateschedule',:via => [:get,:post]
      get '/myschedule', to: 'appointment_schedules#myschedule'
      get '/show_appschedules/:id',to:'appointment_schedules#show_appschedules'
    end
  end
  #resources :appointment_cancel_schedules do
  #  collection do
  #    post '/destroy', to: 'appointment_cancel_schedules#destroy'
  #  end
  #end
  resource :patients do
    collection do
      get '/get_aspects', to: 'patients#get_aspects'
      match '/patientpage/:id', to: 'patients#patient_page', via: [:get, :delete]
      get '/patientfriends', to: 'patients#friends'
      get '/change_main_doctor', to: 'patients#change_main_doctor'
      get '/public_verification', to:'patients#public_verification'
      get '/my_doctors',to:'patients#show_doctors'
    end
  end

  resources :photos do
    collection do
      post '/upload', to: 'photos#create'
    end
  end
  resources :health_records do
    collection do
      get '/play_video', to: 'health_records#play_video'
      get '/ct', to: 'health_records#ct'
      get '/ultrasound', to: 'health_records#ultrasound'
      get '/get_video', to: 'health_records#get_video'
      get '/go_where', to: 'health_records#go_where'
      get '/inspection_report', to: 'health_records#inspection_report'

      post '/ct2',to: 'health_records#ct2'
      post '/ultrasound2',to: 'health_records#ultrasound2'
      post '/inspection_report2',to: 'health_records#inspection_report2'
      post '/dicom',to:'health_records#dicom'
      post '/get_data',to: 'health_records#get_data'
      post '/inspection', to: 'health_records#inspection'
      post '/undefined_other', to: 'health_records#undefined_other'
    end
  end

  get "/consultations/:id/edit" => 'consultations#edit'
  resources :consultations do
    collection do
      match ':action/:id',:via => [:post,:get]
    end
  end
  resources :channels do
    resources :messages
  end
  resources :cons_orders do
    collection do
      match ':action/:id',:via => [:post,:get]
    end
  end
  #resources :consultation_create_records
  #match '/consultations/neworder' => 'consultations#neworder',,:via => [:post,:get]

  resources :reports, only: [:edit, :show, :update]
  resource :notifications do
    collection do
      get '/get_doc_notices', to: 'notifications#get_doc_notices'
      get '/get_pat_notices', to: 'notifications#get_pat_notices'
      get '/pat_app_notices_all', to: 'notifications#pat_app_notices_all'
      get '/doc_fri_notices_all', to: 'notifications#doc_fri_notices_all'
      get '/doc_app_notices_all', to: 'notifications#doc_app_notices_all'
      post '/add_fri_doc', to: 'notifications#add_fri_doc'
      post '/add_con_doc', to: 'notifications#add_con_doc'
      post '/add_main_doc', to: 'notifications#add_main_doc'
      get 'get_all_notice', to: 'notifications#get_all_notice'
      post 'agree_request', to: 'notifications#agree_request'
      delete 'reject_or_delete_notice', to: 'notifications#reject_or_delete_notice'
      delete 'del_con_doc', to: 'notifications#del_con_doc'
      delete 'del_con_pat', to: 'notifications#del_con_pat'
      get '/show_all_notice', to: 'notifications#show_all_notice'
      get 'get_app_notice', to: 'notifications#get_app_notice'
      post '/delUser', to: 'notifications#delUser'

      get '/show_doctor_notices',to:'notifications#show_doctor_notices'
      get '/show_patient_notices',to:'notifications#show_patient_notices'

      get 'get_app_notices', to:'notifications#get_app_notices'
      get 'get_con_notices', to:'notifications#get_con_notices'
    end
  end

  resource :mimas_data_sync_queue do
    collection do
      post '/create', to: 'mimas_data_sync_queue#create'
      post '/destroy', to: 'mimas_data_sync_queue#destroy'
      post '/change', to: 'mimas_data_sync_queue#change'
      get '/show', to:'mimas_data_sync_queue#show'      #同步接口
      get '/destroy_by_id', to:'mimas_data_sync_queue#destroy_by_id'     #同步接口
      post '/find_by_id',to:'mimas_data_sync_queue#find_by_id'     #同步接口
      post 'create_user',to:'mimas_data_sync_queue#create_user'
    end
  end

  resource :blood_glucose do
    collection do
      post '/create',to:'blood_glucose#create'
      post 'show',to:'blood_glucose#show'
      get 'all_glucose_data',to:'blood_glucose#all_glucose_data'
    end
  end

  resource :blood_pressure do
    collection do
      post 'create',to:'blood_pressure#create'
      post 'show',to:'blood_pressure#show'
      get 'all_blood_pressure',to:'blood_pressure#all_blood_pressure'
    end

  end

  resource :weight do
    collection do
      post 'create',to:'weight#create'
      post 'show',to:'weight#show'
      get 'all_weight_data',to:'weight#all_weight_data'
    end
  end

  resource :blood_oxygen do
    collection do
      post 'show',to:'blood_oxygen#show'
      post 'create',to:'blood_oxygen#create'
      get 'all_oxygen',to:'blood_oxygen#all_oxygen'

    end
  end
  resource :pacs_data do
    collection do
      post '/sync_result', to: 'pacs_data#sync_result'
      post '/sync_result_save', to: 'pacs_data#sync_result_save'
    end
  end

  resource :blood_fat do
    collection do
      post 'show',to:'blood_fat#show'
      post 'create',to:'blood_fat#create'
      get'all_blood_fat',to:'blood_fat#all_blood_fat'
    end
  end
  resource :case do
    collection do
      get '/first_case', to:'case#first_case'
      get '/second_case', to:'case#second_case'
      get '/third_case', to:'case#third_case'
      get '/fourth_case', to:'case#fourth_case'
      get '/fifth_case', to:'case#fifth_case'
      get '/sixth_case', to:'case#sixth_case'
      get 'play_video', to:'case#play_video'
    end
  end
  #移动终端接口
  resource :mobile_terminal do
    collection do
      get '/baby_reports', to: 'mobile_terminal#baby_reports'
      get '/baby_pictures', to: 'mobile_terminal#baby_pictures'
      get '/baby_videos', to: 'mobile_terminal#baby_videos'
    end
  end
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
