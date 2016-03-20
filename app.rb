require 'bundler'
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

    # routing
    # get member
    get '/members' do
      Api::Member.all.to_json
    end

    # get member's entries
    get '/member/:id/entries' do
      @entries = Api::Entry.where("member_id = ?", params[:id])
                .where("id > ?", params[:skip].present? ? params[:skip] : 0)
                .limit(params[:limit].present? ? params[:limit] : 30)
                .order(published: :desc)
      jbuilder :entries
    end

    # get all entries
    get '/entries' do
      @entries = Api::Entry.where("id > ?", params[:skip].present? ? params[:skip] : 0)
                .limit(params[:limit].present? ? params[:limit] : 30)
                .order(published: :desc)
      jbuilder :entries
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

  end

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

end
