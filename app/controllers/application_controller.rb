require 'net/http'
require 'json'
require 'uri'
require 'ropenstack'

##Repeated rest call types. Called by other controllers to make requests to OpenStack
class ApplicationController < ActionController::Base
  rescue_from Ropenstack::RopenstackError, :with => :error_respond
#  before_filter :check_auth

  def check_auth()
    authorized = false
    token = request.headers['X-Auth-Token']
    unless token.nil?
      userData = Donabe::KEYSTONE.token(token)
      for role in userData['access']['user']['roles']
        for rule in APP_CONFIG['policy']["#{params[:controller]}:#{params[:action]}"]
          authorized = true if role['name'] == rule['role']
        end
      end
    end
    if (!authorized and (rules.length > 0)) \
      or (userData['access']['token']['tenant']['id'] != params[:tenant_id]) \
      or token.nil?
      respond_to do |format|
        format.json { render :json => {"DonabeError"=>"Unauthorized"}, :status => 401 }
      end
    end
  end

  def error_respond(exception)
    case exception
    when Ropenstack::NotFoundError then
      code = 404
      message = "Unable to locate on openstack, 404 - Not Found Exception"
    when Ropenstack::UnauthorisedError then
      code = 401
      message = "You are unauthorised to perform this action on openstack."
    when Ropenstack::TimeoutError then
      code = 408
      message = "Connecting to openstack took to long." +
                   "Please check your connection and try again."
    else
      code = 500
      message = "There has been an error talking to openstack" 
    end	
    
    logger.info(exception.to_s)
    logger.info(message)

    respond_to do |format|
      format.json { render :json => JSON.parse(exception.to_s), :status => code }
    end
  end

  def build_headers()
    headers = {'Content-Type' =>'application/json'}
    if cookies[:current_token].present?
      headers['X-Auth-Token'] = Storage.find(cookies[:current_token]).data
    end
    return headers
  end

  def build_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 10
    http.read_timeout = 10
    return http
  end

  def response_handle(response)
    if(response.kind_of? Net::HTTPSuccess)
      respond_to do |format|
        format.json { render :json => response.body }	
      end	
    else
      logger.info(response.body)
      respond_to do |format|
        format.json { render :json => response.body, :status => response.code }	
      end	
    end
  end

  def json_respond(list)
          respond_to do |format|
                  format.json { render :json => list }
          end
  end

  def get_request(uri)
          http = build_http(uri)
          request = Net::HTTP::Get.new(uri.request_uri, initheader = build_headers())
          return http.request(request)
  end

  def delete_request(uri)
          http = build_http(uri)
          request = Net::HTTP::Delete.new(uri.request_uri, initheader = build_headers())
          return http.request(request)
  end

  def put_request(uri, body)
          http = build_http(uri)
          request = Net::HTTP::Put.new(uri.request_uri, initheader = build_headers())
          request.body = body
          return http.request(request)		
  end

  def post_request(uri, body)
          http = build_http(uri)
          request = Net::HTTP::Post.new(uri.request_uri, initheader = build_headers())
          request.body = body
          return http.request(request)		
  end

  def keystone_address(endpoint)
          ip = APP_CONFIG["keystone"]["ip"]
          port = APP_CONFIG["keystone"]["port"]
          return URI.parse("http://" + ip + ":" + port.to_s + '/v2.0' + endpoint)
  end

  def nova()
          novaIP = URI.parse(Storage.find(cookies[:nova_ip]).data)
          return Ropenstack::Nova.new(novaIP, Storage.find(cookies[:current_token]).data)
  end
  
  def keystone()
  end

  def cinder()
          cinderIP = URI.parse(Storage.find(cookies[:cinder_ip]).data)
          return Ropenstack::Cinder.new(cinderIP, Storage.find(cookies[:current_token]).data)
  end

  def quantum()
          quantumIP = URI.parse(Storage.find(cookies[:quantum_ip]).data)
          return Ropenstack::Quantum.new(quantumIP, Storage.find(cookies[:current_token]).data)
  end

  def glance()
          glanceIP = URI.parse(Storage.find(cookies[:glance_ip]).data)
          return Ropenstack::Glance.new(glanceIP, Storage.find(cookies[:current_token]).data)
  end

  def glance_address(endpoint)
          glanceIP = URI.parse(Storage.find(cookies[:glance_ip]).data)
          uri = URI.parse("http://" + glanceIP.host + ":" + glanceIP.port.to_s + "/" + endpoint)

          return uri
  end

  def cinder_address(endpoint)
          cinderIP = URI.parse(Storage.find(cookies[:cinder_ip]).data)
          uri = URI.parse("http://" + cinderIP.host + ":" + cinderIP.port.to_s + "/v1/" + Storage.find(cookies[:current_tenant]).data + endpoint)
          return uri
  end
end
