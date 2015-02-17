require './models'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/contrib'
require 'pry'
require 'json'
require 'nokogiri'
require 'builder'

class WebApp < Sinatra::Base
  register Sinatra::Contrib
  
  DOCKETS = Filing.pluck(:docket_number).uniq
  
  def example_query
    [
      "12-80",
      "12-83 ex parte",
      "comments 12-80",
      "reply comments of public knowledge 12-80",
      "verizon ex parte",
      "10-90 petition for waiver",
      "fiber to the home",
      "notice of proposed rulemaking",
      "14-261 nprm",
      "consumer and governmental affairs bureau",
      "wireless telecommunications bureau",
      "22 FCC Rcd 17791",
      "16 FCC Rcd 6547"
    ].sample
  end
  
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
    erb :index, locals: {dockets: DOCKETS[0..8], query: nil, example_query: example_query}, layout: false
  end
  
  get '/search' do
    @title = 'search'
    query = params['q']
    @title << " | #{query}" if !query.empty?
    
    results, docket_number, fcc_rcd = Filing.all_search(query)
    
    respond_to do |f|
      f.json do
        content_type :json
        return {results: results, fcc_rcd: fcc_rcd}.to_json
      end
      f.html do
        if results.length == 1 && fcc_rcd.nil?
          redirect(results.first.fcc_url)
        elsif results.length == 0 && !fcc_rcd.nil?
          redirect(fcc_rcd[:url])
        else
          erb :search, locals: {results: results, query: query, example_query: example_query, fcc_rcd: fcc_rcd, params: params}
        end
      end
    end

  end
  
  get '/search.json' do
    content_type :json      
    query = params['q']
    results, docket_number, fcc_rcd = Filing.all_search(query)

    return {results: results, fcc_rcd: fcc_rcd}.to_json
  end
  
  get '/search.rss' do
    query = params['q']
    results, docket_number, fcc_rcd = Filing.all_search(query)

    builder :rss, locals: {results: results, fcc_rcd: fcc_rcd, query: query}
  end
  
  get '/search.xml' do
    content_type :xml
    query = params['q']
    results, docket_number, fcc_rcd = Filing.all_search(query)

    xml_results = results.map do |result|
      {
        docket_number: result.docket_number,
        name_of_filer: result.name_of_filer,
        type_of_filing: result.type_of_filing,
        fcc_url: result.fcc_url,
        fcc_id: result.fcc_id,
        citation: result.citation,
        date_received: result.date_received
      }
    end
    
    return {results: xml_results, fcc_rcd: rcc_rcd}.to_xml
  end
  
  get '/all' do
    @title = 'all dockets'
    erb :all, locals: {dockets: DOCKETS}
  end
  
  get '/developers' do
    @title = 'developers'
    erb :developers
  end

end