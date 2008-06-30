require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'syntaxi'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/toopaste.sqlite3")

class Snippet
  include DataMapper::Resource

  property :id,         Integer, :serial => true    # primary serial key
  property :body,       Text,    :nullable => false # cannot be null
  property :created_at, DateTime
  property :updated_at, DateTime
  
  validates_present :body
  validates_length :body, :minimum => 1
  
  Syntaxi.line_number_method = 'floating'
  Syntaxi.wrap_at_column = 80
  #Syntaxi.wrap_enabled = false
  
  def formatted_body
    replacer = Time.now.strftime('[code-%d]')
    html = Syntaxi.new("[code lang='ruby']#{self.body.gsub('[/code]', replacer)}[/code]").process
    "<div class=\"syntax syntax_ruby\">#{html.gsub(replacer, '[/code]')}</div>"
  end
end

DataMapper.auto_upgrade!
#File.open('toopaste.pid', 'w') { |f| f.write(Process.pid) }

# new
get '/' do
  erb :new
end

# create
post '/' do
  @snippet = Snippet.new(:body => params[:snippet_body])
  if @snippet.save
    redirect "/#{@snippet.id}"
  else
    redirect '/'
  end
end

# show
get '/:id' do
  @snippet = Snippet.get(params[:id])
  erb :show
end
