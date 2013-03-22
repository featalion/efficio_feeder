require 'yaml'
require 'json'
require 'base64'
require 'open-uri'
require 'rss'

require 'iron_cache'
require 'iron_mq'

module EfficioFeeder

  class Worker

    COMPOSITE_PREFIX = '!!!composite: '
    MAX_FEED_SIZE = 700_000
    KEY_SEPARATOR = ' | '

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
      if previous = get_latest_feed(key)
        pfeed = RSS::Parser.parse(previous)
        remove_old_items(feed, pfeed)
      end

      feed = feed.to_feed(output_type) if output_type

      messages = feed.items.map do |item|
        { body: {feed_url: url, item: item.to_s}.to_json }
      end
      @queue.post(messages) if messages.size > 0

      put_latest_feed(key, response)

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
                       nil_or_equal?(citem.id, oitem.id)
                     when 'rss'
                       nil_or_equal?(citem.guid, oitem.guid)
                     end
          link_check = nil_or_equal?(citem.link, oitem.link)

          id_check || link_check
        end
      end

      current_feed
    end

    def nil_or_equal?(which, to)
      which.nil? || which.to_s == to.to_s
    end

    def get_latest_feed(key)
      latest = @cache.get(key)
      return nil if latest.nil?

      feed = latest.value
      feed = merge_feed(feed) if composite_feed?(feed)

      feed
    end

    def put_latest_feed(key, feed)
      if feed.size > MAX_FEED_SIZE
        split_feed(key, feed)
      else
        @cache.put(key, feed.to_s)
      end
    end

    def split_feed(key, feed)
      keys = []
      part = nil
      while true do
        k = "#{key}_#{keys.size}"
        start_pos = keys.size * MAX_FEED_SIZE
        part = feed[start_pos...start_pos+MAX_FEED_SIZE]

        unless part.nil? || part.empty?
          @cache.put(k, part)
          keys << k
        else
          break
        end
      end

      @cache.put(key, "#{COMPOSITE_PREFIX}#{keys.join(KEY_SEPARATOR)}"
    end

    def merge_feed(keys_storage)
      keys = get_composite_keys(keys_storage)
      keys.each_with_object(String.new) do |key, feed|
        item = @cache.get(key)
        if item
          feed << item.value
          item.delete
        else
          raise 'Composite feed is corrupted!'
        end
      end
    end

    def composite_feed?(feed)
      feed =~ /^#{COMPOSITE_PREFIX}/
    end

    def get_composite_keys(storage)
      storage.sub(/^#{COMPOSITE_PREFIX}/, '').split(KEY_SEPARATOR)
    end

  end

end

# run the feed processing
EfficioFeeder::Worker.new.process
