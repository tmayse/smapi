require 'httparty'
require 'json'

class SMapi
  include HTTParty
  
  base_uri 'https://api.surveymonkey.net'
  format :plain #this keeps HTTParty from automatically parsing the response as JSON - I'll do that myself
  # debug_output $stderr

  @@get_survey_list_url = '/v2/surveys/get_survey_list'
  @@get_respondent_list_url = '/v2/surveys/get_respondent_list'
  @@get_collector_list_url = '/v2/surveys/get_get_collector_list'
  @@get_survey_details_url = '/v2/surveys/get_survey_details'
  @@get_responses_url = '/v2/surveys/get_responses'
  @@get_response_counts_url = '/v2/surveys/get_response_counts'
  @@get_user_details_url = '/v2/user/get_user_details'
  
  @@oauth_authorize_url = '/oauth/authorize'
  @@oauth_token_url = '/oauth/token'
  
  def initialize(api_key, access_token)
    
    # ensure api_key and access_token quack like a string
    return nil unless (api_key.respond_to?(:to_str) && access_token.respond_to?(:to_str)) 
    
    @api_key = api_key.to_str
    @access_token = access_token.to_str
    @headers = {
      'Authorization' => "bearer #{@access_token}",
      'Content-type' => 'application/json'
    }
  end
  
  def self.build_authorize_url(api_key,client_id,redirect_uri)
    return default_options[:base_uri] + @@oauth_authorize_url + "?response=code&api_key=#{api_key}&client_id=#{client_id}&redirect_uri=#{URI::encode(redirect_uri)}"
  end
  
  def self.exchange_code_for_token(api_key, client_id, redirect_uri, client_secret, code)
    response = self.class.post(@@oauth_token_url, :query => { :api_key => api_key}, :body => {:grant_type => 'authorization_code', :client_id => client_id, :redirect_uri => redirect_uri, :client_secret => client_secret})
    unless response.success?
      return nil
    else
      return JSON.parse(response, {:symbolize_names => true})[:access_token]
    end
  end

  def get_user_details
    response = self.class.post(@@get_user_details_url, :body => {}.to_json, :query => {:api_key => @api_key}, :headers => @headers)
    unless response.success?
      return nil
    else
      return JSON.parse(response, {:symbolize_names => true})
    end
  end
end

my_account = SMapi.new( api_key = 'YOUR_API_KEY', access_token = 'YOUR_ACCESS_TOKEN' )
print my_account.get_user_details.to_json
