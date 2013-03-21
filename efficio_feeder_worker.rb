require 'yaml'
require 'json'
require 'base64'
require 'open-uri'
require 'rss'

require 'iron_cache'
require 'iron_mq'

module EfficioFeeder

  class Worker

    def initialize(config_file = 'config.yaml')
      @config = YAML.load_file(config_file)

      @iron_mq = IronMQ::Client.new
      @iron_cache = IronCache::Client.new
    end

    def process
      @config['streams'].each do |stream|
        prepare_queue(stream)
        @cache = @iron_cache.cache(stream['cache_name'])

        stream['feeds'].each { |url| process_feed(url, stream['output_type']) }
      end
    end


    private

    def process_feed(url, output_type)
      feed = nil
      response = nil
      open(url) do |resp|
        response = resp.read
        feed = RSS::Parser.parse(response)
      end

      key = generate_key(url)
      if previous = @cache.get(key)
        pfeed = RSS::Parser.parse(previous.value)
        remove_old_items(feed, pfeed)
      end

      feed = feed.to_feed(output_type) if output_type

      messages = feed.items.map do |item|
        { body: {feed_url: url, item: item.to_s}.to_json }
      end
      @queue.post(messages) if messages.size > 0

      @cache.put(key, response.to_s)

      feed
    end

    def prepare_queue(stream)
      @queue = @iron_mq.queue(stream['queue_name'])

      subscribers = stream['subscribers'].map { |s| {url: s} }
      @queue.update({ push_type: 'multicast',
                      retries: 5,
                      retries_delay: 60,
                      subscribers: subscribers })
    end

    def generate_key(url)
      Base64.urlsafe_encode64(url)
    end

    def remove_old_items(current_feed, previous_feed)
      previous_feed.items.each do |oitem|
        current_feed.items.delete_if do |citem|
          id_check = case current_feed.feed_type
                     when 'atom'
                       nil_or_equal(citem.id, oitem.id)
                     when 'rss'
                       nil_or_equal(citem.guid, oitem.guid)
                     end
          link_check = nil_or_equal(citem.link, oitem.link)

          id_check || link_check
        end
      end

      current_feed
    end

    def nil_or_equal(which, to)
      which.nil? || which.to_s == to.to_s
    end

  end

end

# run the feed processing
EfficioFeeder::Worker.new.process
