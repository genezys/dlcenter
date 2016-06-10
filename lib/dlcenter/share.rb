require 'securerandom'

module DLCenter
  class Share
    attr_reader :uuid, :client
    attr_accessor :content_type, :name, :size

    def initialize client, options = {}
      @client = client
      @uuid = SecureRandom.uuid
      self.content_type = options[:content_type]
      self.name = options[:name]
      self.size = options[:size]
    end

    def content(out)
      Streamer.new(self, out).tap do |stream|
        client.ask_for_stream(stream)
      end
    end

    def size=(size)
      @size = size.to_i
    end
  end
end
