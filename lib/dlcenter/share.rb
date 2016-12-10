require 'securerandom'
require 'zip'
require 'zip_tricks'

module DLCenter
  class Share
    attr_reader :uuid, :client, :oneshot, :inline_content
    attr_accessor :content_type, :name, :size

    def initialize client, options = {}
      @client = client
      @uuid = options[:uuid]
      @uuid ||= SecureRandom.uuid
      raise "Invalid option : #{options.class} #{options}" unless options.class == Hash
      self.content_type = options[:content_type]
      self.name = options[:name]
      self.size = options[:size]
      @inline_content = options[:content]
      @oneshot = options[:oneshot]
      raise "Must have a name" unless self.name
    end

    def self.content(shares, out)
      w = ZipTricks::BlockWrite.new { |chunk| out.write(chunk) }
      ZipTricks::Streamer.open(w) do |zip|
        shares.each do |share|
          zip.write_deflated_file(share.name) do |sink|
            r, w = IO.pipe
            share.content(w)
            while true
              buffer = r.read(65536)
              sink << buffer
              break if buffer.size < 65536
            end
          end
        end
      end
    ensure
      out.close
    end

    def content(out)
      Streamer.new(self, out).tap do |stream|
        client.ask_for_stream(stream)
      end
    end

    def size=(size)
      @size = size.to_i unless size.nil?
    end
  end
end
