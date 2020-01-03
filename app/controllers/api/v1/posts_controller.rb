module Api
  module V1
    class PostsController < ::ApplicationController
      def index
        page = params[:page]
        render json: paginate(::Crawler.fetch_news_list_from_cache, page: page)
      end

      def show
        news = ::Crawler.fetch_news_list_from_cache.select{|n| n[:id].to_i == params[:id].to_i}.first
        render json: news
      end
    end
  end
end