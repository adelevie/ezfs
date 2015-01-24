require './models'
require 'bundler/setup'
require 'sinatra'
require 'pry'
require 'json'

class WebApp < Sinatra::Base
  
  DOCKETS = Filing.pluck(:docket_number).uniq
  
  set :public_folder, File.dirname(__FILE__) + '/public'
  
  configure do
    enable :logging
    file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end
  
  #set :public_folder, 'public'
  
  get '/' do
    @title = 'home'
    erb :index, locals: {dockets: DOCKETS[0..8]}
  end
  
  get '/all' do
    @title = 'all dockets'
    erb :all, locals: {dockets: DOCKETS}
  end
  
  get '/developers' do
    @title = 'developers'
    erb :developers
  end

  DOCKETS.each do |docket_number|
    get "/#{docket_number}" do
      @title = "docket number #{docket_number}"
      erb :search, locals: {docket_number: docket_number, results: nil}
    end
    
    get "/#{docket_number}/search" do
      @title = "search results for docket dumber #{docket_number}"
      query = params['q']
      docket_number = docket_number
      
      results = Filing.docket_search(docket_number, query)
      if results.length == 1
        redirect results.first.fcc_url
      else
        erb :search, locals: {docket_number: docket_number, results: results}
      end
    end
    
    get "/#{docket_number}/search.json" do
      content_type :json
      query = params['q']
      docket_number = docket_number
  
      results = Filing.docket_search(docket_number, query)
  
      return {results: results}.to_json
    end
  end

end