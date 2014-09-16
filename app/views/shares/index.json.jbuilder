json.array!(@shares) do |share|
  json.extract! share, :id, :note_id, :from_user_id, :from_user_name, :share_user_id, :share_user_name, :share_type, :link
  json.url share_url(share, format: :json)
end
