require 'rails_helper'

module Api
  module V1
    describe PostsController do
      let(:news_list) { [{id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}] }

      describe '#index' do
        it "should return a list of news of given page and per_page_params" do
          allow(::Crawler).to receive(:fetch_news_list_from_cache).and_return(news_list)
          get :index, params: {page: 2, per_page: 3}

          expect(JSON.parse(response.body).map{|n| n['id']}).to eq [4, 5]
        end

        it "should return raise error if the given page exceeds total page" do
          allow(::Crawler).to receive(:fetch_news_list_from_cache).and_return(news_list)

          expect{get :index, params: {page: 3, per_page: 3}}.to raise_error Pagy::OverflowError
        end

        it "should return no news if the there's no news fetched from original sites" do
          allow(::Crawler).to receive(:fetch_news_list_from_cache).and_return([])
          get :index, params: {page: 1, per_page: 3}

          expect(JSON.parse(response.body)).to eq []
        end

        it "should return pagination header" do
          allow(::Crawler).to receive(:fetch_news_list_from_cache).and_return(news_list)
          get :index, params: {page: 1, per_page: 4}

          per_page = response.header['X-Per-Page'].to_i
          page = response.header['X-Page'].to_i
          total = response.header['X-Total'].to_i

          expect([per_page, page, total]).to eq [4, 1, 5]
        end
      end

      describe 'show' do
        it "should return a news with the given id" do
          allow(::Crawler).to receive(:fetch_news_list_from_cache).and_return(news_list)
          get :show, params: {id: 2}
          expect(JSON.parse(response.body)['id']).to eq 2
        end

        it "should return nil if the there's no news fetched from original sites" do
          allow(::Crawler).to receive(:fetch_news_list_from_cache).and_return([])
          get :show, params: {id: 2}
          expect(JSON.parse(response.body)).to eq nil
        end
      end
    end
  end
end