json.array!(@events) do |event|
  json.extract! event, :event_date, :user, :event_type, :otheruser, :message
  json.url event_url(event, format: :json)
end
