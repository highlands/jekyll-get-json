require "jekyll"
require 'json'
require 'deep_merge'
require 'open-uri'

module JekyllGetJson
  class GetJsonGenerator < Jekyll::Generator
    safe true
    priority :highest

    def generate(site)

      config = site.config['jekyll_get_json']
      if !config
        warn "No config".yellow
        return
      end
      if !config.kind_of?(Array)
        config = [config]
      end

      config.each do |d|
        begin
          target = site.data[d['data']]
          if d['headers']
            headers = d['headers'].map{|k,v| [k, eval("\""+v+"\"")] }.to_h
            source = JSON.load(URI.open(d['json'], headers))
          else
            source = JSON.load(URI.open(d['json']))
          end

          if target
            target.deep_merge(source)
          else
            site.data[d['data']] = source
          end
        rescue
          next
        end
      end
    end
  end
end

