require 'sinatra'

set :bind, '0.0.0.0'
set :port, '8000'

get "/*" do |file|
  send_file file
end