#!/usr/bin/env ruby
require 'net/http'
require 'uri'

httptimeout = 60
ping_count = 10

servers = [
    {name: 'sss-google', url: '8.8.8.8', method: 'ping'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
    {name: 'sss-google', url: 'http://www.google.com/', method: 'http'},
    {name: 'sss-google', url: '8.8.8.8', method: 'ping'},
    {name: 'sss-google', url: '8.8.8.8', method: 'ping'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
    {name: 'sss-google', url: 'http://www.google.com', method: 'http'},
]

SCHEDULER.every '1m', :first_in => 0 do |job|
    servers.each do |server|
        if server[:method] == 'http'
            begin
                uri = URI.parse(server[:url])
                http = Net::HTTP.new(uri.host, uri.port)
                http.read_timeout = httptimeout
                if uri.scheme == "https"
                    http.use_ssl=true
                    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                end
                request = Net::HTTP::Get.new(uri.request_uri)
                response = http.request(request)
                if response.code == "200"
                    result = 1
                else
                    result = 0
                end
            rescue Timeout::Error
                result = 0
            rescue Errno::ETIMEDOUT
                result = 0
            rescue Errno::EHOSTUNREACH
                result = 0
            rescue Errno::ECONNREFUSED
                result = 0
            rescue SocketError => e
                result = 0
            end
        elsif server[:method] == 'ping'
            result = `ping -q -c #{ping_count} #{server[:url]}`
            if ($?.exitstatus == 0)
                result = 1
            else
                result = 0
            end
        end

        send_event(server[:name], result: result)
    end
end
