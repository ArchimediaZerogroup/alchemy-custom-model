
json.meta do
  json.total_count @custom_model_klasses.count
  json.page params[:page]
  json.per_page 10
end
json.results @custom_model_klasses do |result|
  json.id result
  json.text result
end