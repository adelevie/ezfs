require './models'
require 'bundler/setup'
require 'sinatra'
require 'pry'

class WebApp < Sinatra::Base
  
  configure do
    enable :logging
    file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end
  
  set :public_folder, 'public'
  
  get '/' do
    erb :index
  end

  get '/:docket_number' do
    erb :search, locals: {docket_number: params[:docket_number], results: nil}
  end

  get '/:docket_number/search' do
    query = params['q']
    docket_number = params['docket_number']
  
    results = Filing.search(where: {docket_number: docket_number, citation: query})
    if results.length == 0
      results = Filing.search(query, where: {docket_number: docket_number})
    end
  
    if results.length == 1
      redirect results.first.fcc_url
    else  
      erb :search, locals: {docket_number: params[:docket_number], results: results}
    end
  end

end