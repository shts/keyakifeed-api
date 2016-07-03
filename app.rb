require 'bundler'
require 'kconv'
Bundler.require

module Api

  class Application < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end
    configure do
      register Sinatra::ActiveRecordExtension
      set :database, {adapter: "sqlite3", database: "db/api.db"}
    end

    # -----------------------------------------------------
    # Routing
    # -----------------------------------------------------
    # get member
    get '/members' do
      Api::Member.all.to_json
    end

    # get member
    get '/members/:id' do
      member = Api::Member.find_by_id(params[:id])
      if member == nil then
        404
      else
        member.to_json
      end
    end

    # get member's entries
    # /member/entries?id[]=1&id[]=2&limit=0&skip=30
    get '/member/entries' do
      #文字コード指定してやらないと日本語が化ける
    	content_type :json, :charset => 'utf-8'

      @entries = Api::Entry.where(member_id: params[:ids])
                .offset(params[:skip].present? ? params[:skip] : 0)
                .limit(params[:limit].present? ? params[:limit] : 30)
                .order(published: :desc)
      jbuilder :entries
    end

    # get all entries
    # /entries?limit=0&skip=30
    get '/entries' do
    	content_type :json, :charset => 'utf-8'

      @entries = Api::Entry.offset(params[:skip].present? ? params[:skip] : 0)
                .limit(params[:limit].present? ? params[:limit] : 30)
                .order(published: :desc)
      jbuilder :entries
    end

    # get all reports
    # /reports?limit=0&skip=30
    get '/reports' do
      content_type :json, :charset => 'utf-8'

      reports = Api::Report.offset(params[:skip].present? ? params[:skip] : 0)
                .limit(params[:limit].present? ? params[:limit] : 30)
                .order(published: :desc)
      reports.to_json
    end

    # Favorite
    # action 1 -> incriment
    # action -1 -> decriment
    # curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{"member_id":"1","action":"incriment"}' http://localhost:9292/favorite -w "\n%{http_code}\n"
    post '/favorite', provides: :json do
      params = JSON.parse request.body.read
      # "Post Favorite #{params} id -> #{params['member_id']} present -> #{params['member_id'].present?}, action -> #{params['action']} present -> #{params['action'].present?}"
      if !params['member_id'].present? || !params['action'].present? then
        return status 500
      end
      if params['action'] != 'incriment' && params['action'] != 'decriment' then
        return status 500
      end

      member = Api::Member.find_by_id(params['member_id'])
      return status 500 if member == nil

      member.favinc if params['action'] == 'incriment'
      member.favdec if params['action'] == 'decriment'

      member.save
    end

    # /matomes?limit=0&skip=30
    get '/matomes' do
      content_type :json, :charset => 'utf-8'

      reports = Api::Matome.offset(params[:skip].present? ? params[:skip] : 0)
                .limit(params[:limit].present? ? params[:limit] : 30)
                .order(entry_published: :desc)
      reports.to_json
    end

  end

  # DBの設定
  class Member < ActiveRecord::Base
    has_many :entries

    before_save :prepare_save

    def prepare_save
      self.favorite = 0 if self.favorite == nil || self.favorite < 0
      self
    end

    def favinc
      self.favorite = self.favorite + 1
    end

    def favdec
      self.favorite = self.favorite - 1
    end

  end

  class Entry < ActiveRecord::Base
    belongs_to :member
  end

  class Report < ActiveRecord::Base
  end

  class Matome < ActiveRecord::Base
  end

end
