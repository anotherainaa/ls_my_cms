require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'redcarpet'

configure do
  enable :sessions
  set :sessions_secret, 'secret'
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data/, __FILE__")
  else
    File.expand_path("../data", __FILE__)
  end
end

def render_markdown(text)
  markdown =  Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def load_file_content(path)
  content = File.read(path)
  case File.extname(path)
  when ".md"
    erb render_markdown(content)
  when ".txt"
    headers["Content-Type"] = "text/plain"
    content
  end
end

get '/' do
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map do|path|
    File.basename(path)
  end
  erb :index, layout: :layout
end

get '/new' do
  erb :new, layout: :layout
end

post '/create' do
  filename = params[:filename]

  if filename.empty?
    session[:message]= "A name is required."
    status 422
    erb :new
  elsif ![".txt", ".md"].include? File.extname(filename)
    session[:message]= ".txt or .md file extension is required."
    status 422
    erb :new
  else
    file_path = File.join(data_path, filename)
    File.write(file_path, "")
    session[:message] = "#{filename} has been created."
    redirect "/"
  end
end

# Open a document as text file

get '/:filename' do
  file_path = File.join(data_path, params[:filename])

  if File.exist? file_path
    load_file_content(file_path)
  else
    session[:message] = "#{params[:filename]} does not exist."
    redirect '/'
  end
end

# Edit an existing document

get '/:filename/edit' do
  file_path = File.join(data_path, params[:filename])
  @filename = params[:filename]

  if File.exist? file_path
    @content = File.read(file_path)
    erb :edit, layout: :layout
  else
    session[:message] = "#{@filename} does not exist."
    redirect '/'
  end
end

# Updates an existing document

post '/:filename' do
  file_path = File.join(data_path, params[:filename])

  File.open(file_path, "w") { |file| file.write(params[:file_content]) }

  session[:message] = "#{params[:filename]} has been updated."
  redirect "/"
end

# Creata e new document


=begin

Add a link to for users to create new documents
- [x] create a link using a tag on the index page that says new document
- [x] create a route to create a new document - template new
- [x] in the erb, create a form to submit the name of the new document
- [x] in the routes, create this new document. How to create a new document?
- [x] add a validation for the form to say a name is required
-  add test for this

=end
