require "net/http"

module Emulatorization
  module API
    mattr_accessor :host
    mattr_accessor :port
    mattr_accessor :path

    def self.setup
      yield self
    end

    def self.send(request, user_opts = {})
      self.send_string(JSON.generate(request), user_opts)
    end

    def self.send_string(request, user_opts = {})
      # defaults
      opts = {
        open_timeout: 1.second,
        read_timeout: nil
      }
      opts.merge! user_opts

      # opts can only include read_timeout for now
      # pre-check host, port, path been set?
      # loading every time, inefficient!
      all_config = YAML::load(ERB.new(File.read(Rails.root.join('config', 'api.yml'))).result)
      env_config = all_config[Rails.env]
      self.host = env_config['host']
      self.port = env_config['port']
      self.path = env_config['path']

      # setup post request
      post = Net::HTTP::Post.new(self.path)
      post.add_field("Content-Type", "application/json")

      # add body
      post.body = request

      # get response
      begin
        http = Net::HTTP.new(self.host, self.port)
        http.open_timeout = opts[:open_timeout]
        http.read_timeout = opts[:read_timeout]
        res = http.start do |c|
          c.request(post)
        end

        # todo: also get Errno::EADDRINUSE when we can't connect?

        # check OK
        if res.code == '200'
          return JSON.parse(res.body)
        else
          return self.exception_object("#{res.code} returned by API.")
        end
      rescue Errno::ECONNREFUSED
        return self.exception_object("Connection refused by API.")
      rescue Errno::ECONNRESET
        return self.exception_object("Connection reset by API.")
      rescue Errno::ETIMEDOUT
        return self.exception_object("Timeout connecting to API.")
      rescue Timeout::Error
        # seem to get this on connection too?
        return self.exception_object("Timeout from API.")
      rescue JSON::ParserError
        return self.exception_object("Couldn't parse response from API.")
      end
    end

    private

    def self.exception_object(message)
      { 'type' => 'Exception', 'message' => message }
    end
  end
end