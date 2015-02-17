json.array!(@events) do |event|
  json.extract! event, :data, :user, :event_type, :otheruser, :message
  json.url event_url(event, format: :json)
end
