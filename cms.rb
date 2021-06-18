require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

root = File.expand_path("..", __FILE__)

configure do
  enable :sessions
  set :sessions_secret, 'secret'
end

get '/' do
  @files = Dir.glob(root + '/data/*').map { |path| File.basename(path) }

  erb :index
end

# Open a document as text file

get '/:file_name' do
  file_path = root + '/data/' + params[:file_name]
  if File.exist? file_path
    puts "file path #{file_path}"
    headers["Content-Type"] = "text/plain"
    File.readlines(file_path)
  else
    session[:error] = "#{params[:file_name]} does not exist."
    redirect '/'
  end
end
