# server.rb
require 'sinatra'
require 'pg'
require "sinatra/namespace"
require 'rest-client'

set :bind, '0.0.0.0'
set :port, 8080 


get '/' do
    'APIs Optimización Gateway Appliance'
end

namespace '/api/v1' do
  before do
    content_type 'application/json'
  end
####################################################################
#
# Servicios para dimensionamiento de Gateway Appliance
#
####################################################################
  get '/sizingga' do
    logger = Logger.new(STDOUT)
    region="#{params['region']}"
    type="#{params['type']}"
    interfase="#{params['interfase']}"
    pii="#{params['pii']}"
    ha="#{params['ha']}"
    resultado=[]
    nodos=1
    begin
      if ha=="true" then
        nodos=2
      end
      query="SELECT region, type, pii, interfase, price*#{nodos} precio, description FROM public.gateway_appliance_pricing WHERE region='#{region}' and type='#{type}' and pii=#{pii} and interfase=#{interfase}"
      logger.info(query)
      connection = PG.connect :dbname => 'ibmclouddb', :host => '313a3aa9-6e5d-4e96-8447-7f2846317252.0135ec03d5bf43b196433793c98e8bd5.databases.appdomain.cloud',:user => 'ibm_cloud_31bf8a1b_1bbe_49e4_8dc2_0df605f5f88b', :port=>31184, :password => '535377ecca248285821949f6c71887d73a098f00b6908a645191503ab1d72fb3'
      t_messages = connection.exec query
      t_messages.each do |s_message|
          resultado.push({ region: s_message['region'],
            type: s_message['type'], pii: s_message['pii'],
            precio: s_message['precio'],
            nodos:  nodos,
            description: s_message['description'] })
      end
      logger.info(resultado.to_s)
    rescue PG::Error => e
      logger.info(e.message.to_s)
    ensure
      connection.close if connection
    end
    resultado.to_json
  end

end
