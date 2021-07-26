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
    logger.info("Tipo de gateway: #{type}")
    if type=="strongswan"
      resultado.push({ region: region,
            type: "strong swan", pii: false,
            precio: 0,
            nodos:  0,
            description: "Incluido en el clúster de IKS/Openshift" })
            logger.info(resultado.to_s)
    else
      if ha=="true"
        nodos=2
      end
      begin
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
              logger.info(resultado.to_s)
        end
      rescue PG::Error => e
        logger.info(e.message.to_s)
      ensure
        connection.close if connection
      end
    end
  resultado.to_json
  end

  get '/sizingdl' do
    logger = Logger.new(STDOUT)
    region="#{params['region']}"
    type="#{params['type']}"
    country_offer="#{params['country_offer']}"
    puerto="#{params['puerto']}"
    routing="#{params['routing']}"
    ha="#{params['ha']}"
    resultado=[]
    nodos=1
    if ha=="true"
      nodos=2
    end
    begin
      query="SELECT region, puerto, country_offer, type, price*#{nodos} as precio, routing FROM public.dl_pricing WHERE region='#{region}' and type='#{type}' and puerto='#{puerto}' and country_offer='#{country_offer}' and routing='#{routing}'";
      logger.info(query)
      connection = PG.connect :dbname => 'ibmclouddb', :host => '313a3aa9-6e5d-4e96-8447-7f2846317252.0135ec03d5bf43b196433793c98e8bd5.databases.appdomain.cloud',:user => 'ibm_cloud_31bf8a1b_1bbe_49e4_8dc2_0df605f5f88b', :port=>31184, :password => '535377ecca248285821949f6c71887d73a098f00b6908a645191503ab1d72fb3'
      t_messages = connection.exec query
      t_messages.each do |s_message|
          resultado.push({ region: s_message['region'],
            puerto: s_message['puerto'], country_offer: s_message['country_offer'],
            type: s_message['type'],
            precio: s_message['precio'],
            nodos:  nodos,
            routing: s_message['routing'] })
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
