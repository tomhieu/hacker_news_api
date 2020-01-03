require 'nokogiri'
require 'open-uri'

class Crawler
  class << self
    URL = 'https://news.ycombinator.com/best'
    SITE = 'https://news.ycombinator.com'
    CACHE_KEY = 'ycombinator_news'
    TOTAL_PAGE = 7

    def fetch_news_list_from_cache
      Rails.cache.fetch(get_cache_key) do
        get_all_news
      end
    end

    def update_all_cache
      Rails.cache.write(get_cache_key, get_all_news)
    end

    def get_all_news
      list = []
      (1..TOTAL_PAGE).each do |page|
        list += get_news_list(page)
      end
      list
    end

    # get  news list in 1 page of news.ycombinator.com/best
    def get_news_list(page=1)
      news_list = []
      doc = Nokogiri::HTML(open("#{URL}?p=#{page}"))
      doc.xpath("//body//table[@id='hnmain']//table[@class='itemlist']//tr").select{|tr| tr['class'].in? ['athing', nil]}.each_slice(2) do |nodes|
        title_node, meta_node = nodes
        next if title_node.nil? || meta_node.nil?

        id = title_node.xpath("./td").first&.content&.gsub('.', '').to_i
        title = title_node.xpath("./td[@class=$t]/a", nil, t: 'title').first&.content
        site = title_node.xpath("./td[@class=$t]/span/a", nil, t: 'title').first&.content
        original_url = title_node.xpath("./td[@class=$t]/a", nil, t: 'title').first['href']
        original_url = is_internal_link?(original_url) ? "#{SITE}/#{original_url}" : original_url

        score = meta_node.xpath("./td[@class=$t]/span[@class=$c]", nil, t: 'subtext', c: 'score').first&.content&.split(' ')&.first&.to_i
        user = meta_node.xpath("./td[@class=$t]/a[@class=$c]", nil, t: 'subtext', c: 'hnuser').first&.content
        created_time = meta_node.xpath("./td[@class=$t]/span[@class=$c]", nil, t: 'subtext', c: 'age').first&.content
        comments = meta_node.xpath("./td[@class=$t]/a[last()]", nil, t: 'subtext').first&.content&.split(' ')&.first
        begin
          detail_doc = Nokogiri::HTML(open(original_url))
        rescue
          # TODO notify admin
          next # skip this news
        end

        cover_image = (img = detail_doc.xpath("//meta[@property='og:image']").first) ? img['content'] : nil
        cover_image ||= (img = detail_doc.xpath("//img").first) ? img['src'] : nil
        cover_image = URI.join(original_url, cover_image).to_s if cover_image.present?
        # default cover image of news
        cover_image ||= "https://news.ycombinator.com/y18.gif"
        content = detail_doc.xpath("//p").map(&:content)

        news = {
          id: id,
          title: title,
          site: site,
          original_url: original_url,
          score: score,
          user: user,
          created_time: created_time,
          comments: comments,
          cover_image: cover_image,
          content: content
        }

        news_list.push(news)
      end
      news_list
    end

    private

    def is_internal_link?(link)
      !link.include?('//')
    end

    def get_cache_key
      CACHE_KEY
    end
  end
end