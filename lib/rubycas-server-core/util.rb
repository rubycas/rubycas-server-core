require 'uri'
module RubyCAS::Server::Core
  module Util
    extend self

    def build_ticketed_url(url, ticket)
      parsed = URI.parse(url)
      query = parsed.query.to_s
      params = query.split('&')
      params << "ticket=#{ticket}"
      parsed.query = params.join('&')
      parsed.to_s
    end

    PARAM_REGEX = /(?:service|gateway|renew|ticket)=[^&]+/
    def clean_service_url(dirty_url)
      parsed = URI.parse(dirty_url)
      query = parsed.query.to_s # we really only care about the query portion of the url
      query.gsub!(PARAM_REGEX, '')
      query.gsub!(/[\/\?&]$/, '')
      query.gsub!(/&&/, '&')
      query.gsub!(/^&/, '')
      parsed.query = query.blank? ? nil : query
      parsed.to_s
    end
  end
end
