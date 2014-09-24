# Ruby on Rails チュートリアル：サンプルアプリケーション

これは、以下のためのサンプルアプリケーションです。
[*Ruby on Rails Tutorial*](http://railstutorial.jp/)
by [Michael Hartl](http://michaelhartl.com/).

# google mapを実装し、micropostと連動させるまで

tutorial11章終了時点のsample appを使用  

### Gemを追加

	gem "gmaps4rails"
	gem "geocoder"
install

	bundle installo
以下がインストールされていた(2014/09/01)

	Using geocoder 1.2.4
	Using gmaps4rails 2.1.2

### 緯度経度のデータを格納するModelを作成(これが一つの投稿になる)

	$ rails g scaffold Post title:string description:string content:text address:string latitude:float longitude:float user_id:integer date:datetime -f

      invoke  active_record
      create    db/migrate/20140901130117_create_posts.rb
      create    app/models/post.rb
      invoke    rspec
      create      spec/models/post_spec.rb
      invoke  resource_route
       route    resources :posts
      invoke  jbuilder_scaffold_controller
      create    app/controllers/posts_controller.rb
      invoke    erb
      create      app/views/posts
      create      app/views/posts/index.html.erb
      create      app/views/posts/edit.html.erb
      create      app/views/posts/show.html.erb
      create      app/views/posts/new.html.erb
      create      app/views/posts/_form.html.erb
      invoke    rspec
      create      spec/controllers/pmsts_controller_spec.rb
      create      spec/views/posts/edit.html.erb_spec.rb
      create      spec/views/posts/index.html.erb_spec.rb
      create      spec/views/posts/new.html.erb_spec.rb
      create      spec/views/posts/show.html.erb_spec.rb
      create      spec/routing/posts_routing_spec.rb
      invoke      rspec
      create        spec/requests/posts_spec.rb
      invoke    helper
      create      app/helpers/posts_helper.rb
      invoke      rspec
      create        spec/helpers/posts_helper_spec.rb
      invoke    jbuilder
       exist      app/views/posts
      create      app/views/posts/index.json.jbuilder
      create      app/views/posts/show.json.jbuilder
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/posts.js.coffee
      invoke    scss
      create      app/assets/stylesheets/posts.css.scss
      invoke  scss
      create    app/assets/stylesheets/scaffolds.css.scss


データベースをマイグレート(reset)

	rake db:migrate

モデルを編集

    class Post < ActiveRecord::Base
      geocoded_by :address
      after_validation :geocode
    end

JSのURLを指定

  views/layouts/application.html.erbに以下をHEAD内に追加


    <script src="//maps.google.com/maps/api/js?v=3.13&amp;sensor=false&amp;libraries=geometry" type="text/javascript"></script>
    <script src='//google-maps-utility-library-v3.googlecode.com/svn/tags/markerclustererplus/2.0.14/src/markerclusterer_packed.js' type='text/javascript'></script>

unserscore.jsを[http://underscorejs.org/underscore-min.js](http://underscorejs.org/underscore-min.js)からコピーし*vender/assts/javascripts/underscore.js*として保存  

*assets/javascripts/application.js*に以下を追記

    //= require underscore
    //= require gmaps/google


app/assets/stylesheets/scaffolds.css.scssの中身をコメントアウトしておく

### static_pagesコントローラ
static_pages_controller.rbのhomeに以下を追加

      @posts = Post.all
      @hash = Gmaps4rails.build_markers(@posts) do |post, marker|
        marker.lat post.latitude
        marker.lng post.longitude
        marker.infowindow post.description
        marker.json({title: post.title})
      end

### viewを編集
app/views/shared/_home_signed_in.html.erbを編集

    <div class="row">
      <aside class="span4">
        <section>
          <%= render 'shared/user_info' %>
        </section>
        <section>
          <%= render 'shared/stats' %>
        </section>
        <section>
          <%= render 'shared/micropost_form' %>
        </section>
      </aside>
      <div class="span8">
        <h3>Micropost Feed</h3>
        <%= render 'shared/feed' %>
      </div>
      //ここから
      <div style='width: 800px;'>
        <div id="map" style='width: 800px; height: 400px;'></div>
      </div>

      <script type="text/javascript">
        handler = Gmaps.build('Google');
        handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
            markers = handler.addMarkers(<%=raw @hash.to_json %>);
            handler.bounds.extendWith(markers);
            handler.fitMapToBounds();
          });
      </script>
      //ここまで
    </div>

追加されたのはこの部分、google Map関連

### Postsコントローラ

      class PostsController < ApplicationController
        before_action :set_post, only: [:show, :edit, :update, :destroy]

        # GET /posts
        # GET /posts.json
        def index
          @posts = Post.all
        end

        # GET /posts/1
        # GET /posts/1.json
        def show
        end

        # GET /posts/new
        def new
          @post = Post.new
        end

        # GET /posts/1/edit
        def edit
        end

        # POST /posts
        # POST /posts.json
        def create
          @post = Post.new(post_params)

          respond_to do |format|
            if @post.save
              format.html { redirect_to @post, notice: 'Post was successfully created.' }
              format.json { render action: 'show', status: :created, location: @post }
            else
              format.html { render action: 'new' }
              format.json { render json: @post.errors, status: :unprocessable_entity }
            end
          end
        end

        # PATCH/PUT /posts/1
        # PATCH/PUT /posts/1.json
        def update
          respond_to do |format|
            if @post.update(post_params)
              format.html { redirect_to @post, notice: 'Post was successfully updated.' }
              format.json { head :no_content }
            else
              format.html { render action: 'edit' }
              format.json { render json: @post.errors, status: :unprocessable_entity }
            end
          end
        end

        # DELETE /posts/1
        # DELETE /posts/1.json
        def destroy
          @post.destroy
          respond_to do |format|
            format.html { redirect_to posts_url }
            format.json { head :no_content }
          end
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_post
            @post = Post.find(params[:id])
          end

          # Never trust parameters from the scary internet, only allow the white list through.
          def post_params
            params.require(:post).permit(:title, :description, :content, :address, :latitude, :longitude, :user_id, :date)
          end
      end

### Postのdescriptionをマイクロにする(文字制限)
      class Post < ActiveRecord::Base
            validates :description, length: { maximum: 140 }
      end

### ユーザーとPostを関連付ける
app/models/user.rbに以下を追加

      has_many :posts
一人のユーザーに複数のポストがある  

app/models/post.rbに以下を追加

      class Post < ActiveRecord::Base
          belongs_to :user
          validates :description, length: { maximum: 140 }
          geocoded_by :address
          after_validation :geocode
      end
1つのポストは1つのユーザーにのみ属する


## レイアウト
### ヘッダー
app/views/layouts/_header.html.erbのlink_toの箇所にSpotを以下のように追加

        <ul class="nav pull-right">
          <li><%= link_to "Home", root_path %></li>
          <li><%= link_to "Spot", '#' %></li>  //ここに追加
          <li><%= link_to "Help", help_path %></li>
          <% if signed_in? %>


## Micropostモデルを踏襲する
postsテーブルを作成するためのマイグレーションファイルを作成

    class CreatePosts < ActiveRecord::Migration
      def change
        create_table :posts do |t|
          t.string :title
          t.string :description
          t.text :content
          t.string :address
          t.float :latitude
          t.float :longitude
          t.integer :user_id
          t.datetime :date

          t.timestamps
        end
        add_index :posts, [:user_id, :created_at]  //ここを追加
      end
    end
user_idに関連付けられた全てのpostを作成時刻の逆順で取り出す

    rake db:migrate
    reke test:prepare


#### postを投稿したユーザーを示すユーザーIDを持たせる
Active Recordの関連付けを行う

    class Post < ActiveRecord::Base
      belongs_to :user
      validates :user_id, presence: true  //ここを追加
      validates :description, length: { maximum: 140 }
      geocoded_by :address
      after_validation :geocode
    end

#### ユーザーのpostがユーザーと一緒に破棄されることを保証する
app/models/user.rbに以下の内容を追加する

    has_many :posts, dependent: :destroy

##### default_scopeでpostを順序付ける
##### app/models/post.rbのdescriptionを必須に
##### app/models/post.rbのtitleを必須に
app/models/post.rbの has_many :postsを以下のように編集  
descriptionにpresence: trueを追加
以下が現在のpost.rb  

    class Post < ActiveRecord::Base
      belongs_to :user
      default_scope -> { order('created_at DESC') }
      validates :user_id, presence: true
      validates :title, presence: true, length: { maximum: 30 }
      validates :description, presence: true, length: { maximum: 140 }
      geocoded_by :address
      after_validation :geocode
    end

##### ユーザーのhome画面にポストを追加する
app/views/static_pages/_home_signed_in.html.erbを以下のように編集

    <div class="row">
      <aside class="span4">
        <section>
          <%= render 'shared/user_info' %>
        </section>
        <section>
          <%= render 'shared/stats' %>
        </section>
        <section>
          <%= render 'shared/micropost_form' %>
        </section>
      </aside>
      <div class="span8">
        <h3>Micropost Feed</h3>
        <%= render 'shared/feed' %>
      </div>

    <!--  ここから追加したところ
      <div class="span8">
        <% if @user.posts.any? %>
          <h3>Posts (<%= @user.posts.count %>)</h3>
          <ol class="posts">
            <%= render @posts %>
          </ol>
          <%= will_paginate @posts %>
        <% end %>
      </div>
    ここまで-->

      <div style='width: 800px;'>
        <div id="map" style='width: 800px; height: 400px;'></div>
      </div>

      <script type="text/javascript">
        handler = Gmaps.build('Google');
        handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
            markers = handler.addMarkers(<%=raw @hash.to_json %>);
            handler.bounds.extendWith(markers);
            handler.fitMapToBounds();
          });
      </script>

    </div>

render @postsのパーシャルを作成  
app/views/posts/_post.html.erb

    <li>
      <span class="content"><%= post.content %></span>
      <span class="timestamp">
        Posted <%= time_ago_in_words(post.created_at) %> ago.
      </span>
    </li>

app/controllers/static_pages_controller.rbのhomeに以下を追加

      @posts = current_user.posts.paginate(page: params[:page])

これで、現在のユーザーのpostのみが、home画面に表示されるようになった

#### CSSに以下を追加
    /* posts */

    .posts {
      list-style: none;
      margin: 10px 0 0 0;

      li {
        padding: 10px 0;
        border-top: 1px solid #e8e8e8;
      }
    }
    .content {
      display: block;
    }
    .timestamp {
      color: $grayLight;
    }
    .gravatar {
      float: left;
      margin-right: 10px;
    }
    aside {
      textarea {
        height: 100px;
        margin-bottom: 5px;
      }
    }



#### マイクロポストとポストを揃える(パーシャルを作成)
app/views/shared/_post.html.erbに以下を記述

    <% if @user.posts.any? %>
        <ol class="posts">
        <%= render partial: 'shared/post_item', collection: @post_items %>
        </ol>
        <%= will_paginate @post_items %>
    <% end %>


つづいてapp/views/shared/_post_item.html.erbに以下を記述

    <li id="<%= post_item.id %>">
      <%= link_to gravatar_for(post_item.user), post_item.user %>
          <span class="user">
            <%= link_to post_item.user.name, post_item.user %>
          </span>
          <span class="content"><%= post_item.content %></span>
          <span class="timestamp">
            Posted <%= time_ago_in_words(post_item.created_at) %> ago.
          </span>
    <%#   <%= render 'shared/post_delete_link', object: post_item %>
    </li>

そして_home_signed_in.html.erbを編集

      <div class="span8">
         <% if @user.posts.any? %>
          <h3>Posts (<%= @user.posts.count %>)</h3>
          <%= render 'shared/post' %>
           <ol class="posts">
            <%= render @posts %>
          </ol>
          <%= will_paginate @posts %>
        <% end %>
      </div>

上から下のように編集した

     <div class="span8">
        <h3>Posts (<%= @user.posts.count %>)</h3>
        <%= render 'shared/post' %>
    </div>     

static_pages_controllerを編集

      @post_items = current_user.posts.paginate(page: params[:page])

#### Postsコントローラのアクションに認証を追加する
app/controllers/posts_controller.rb

    before_action :signed_in_user, only: [:create, :new, :destroy, :edit, :update, :show]

#### postコントローラのcreateアクション
元々は以下、これだと全ユーザーのpostがHomeページで表示されてしまう。Homeでは自分のPostだけ表示させたい

    def create
      @post = Post.new(post_params)

      respond_to do |format|
        if @post.save
          format.html { redirect_to @post, notice: 'Post was successfully created.' }
          format.json { render action: 'show', status: :created, location: @post }
        else
          format.html { render action: 'new' }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end
これを次のようにする

    def create
      @post = current_user.posts.build(post_params)  //編集
      respond_to do |format|
        if @post.save
          flash[:success] = "Post created!"           //追加
          format.html { redirect_to @post, notice: 'Post was successfully created.' }
          format.json { render action: 'show', status: :created, location: @post }
        else
          format.html { render action: 'new' }
          format.json { render json: @post.errors, status: :unprocessable_entity }
        end
      end
    end

#### Homeページにポスト作成ボタンを追加する
app/views/shared/_home_signed_inを以下から

    <div class="row">
      <aside class="span4">
        <section>
          <%= render 'shared/user_info' %>
        </section>
        <section>
          <%= render 'shared/stats' %>
        </section>
        <section>
          <%= render 'shared/micropost_form' %>
        </section>
      </aside>
      <div class="span8">
        <h3>Micropost Feed</h3>
        <%= render 'shared/feed' %>
      </div>

      <div class="span8">
          <h3>Posts (<%= @user.posts.count %>)</h3>
          <%= render 'shared/post' %>
      </div>

      <div style='width: 800px;'>
        <div id="map" style='width: 800px; height: 400px;'></div>
      </div>

      <script type="text/javascript">
        handler = Gmaps.build('Google');
        handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
            markers = handler.addMarkers(<%=raw @hash.to_json %>);
            handler.bounds.extendWith(markers);
            handler.fitMapToBounds();
          });
      </script>
    </div>

以下のように編集

    <div class="row">
      <aside class="span4">
        <section>
          <%= render 'shared/user_info' %>
        </section>
        <section>
          <%= render 'shared/stats' %>
        </section>
        <section>
          <%= render 'shared/micropost_form' %>
        </section>
      </aside>
      <div class="span8">
        <h3>Micropost Feed</h3>
        <%= render 'shared/feed' %>
      </div>

      <div class="span8">
          <h3>Posts (<%= @user.posts.count %>)</h3>
          <%= render 'shared/post' %>
      </div>

      <%= link_to "Post up", postup_path, class: "btn btn-large btn-primary" %>  //これを追加

      <div style='width: 800px;'>
        <div id="map" style='width: 800px; height: 400px;'></div>
      </div>

      <script type="text/javascript">
        handler = Gmaps.build('Google');
        handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
            markers = handler.addMarkers(<%=raw @hash.to_json %>);
            handler.bounds.extendWith(markers);
            handler.fitMapToBounds();
          });
      </script>

    </div>

routes.rbに以下を追加

    match '/postup', to: 'posts#new',     via: 'get'

#### post作成フォームのパーシャルを作成する
既存の_formを移動

    mv app/views/posts/_form.html.erb app/views/shared/_post_form.html.erb
renderの部分を

    <%= render 'form' %>
以下のように編集

    <%= render 'shared/post_form' %>

 ついでに、フォームのボタンのクラスを以下のように変えておく

    <div class="actions">
      <%= f.submit class: "btn btn-large btn-primary"%>
    </div>app/views/posts/new.html.erbの以下の行を   

#### Home画面の見た目を変える
Home画面のレイアウトを整える
app/views/shared/_home_signed_in.html.erb

    <div class="row">
      <aside class="span4">
        <section>
          <%= render 'shared/user_info' %>
        </section>
        <section>
          <%= render 'shared/stats' %>
        </section>
        <section>
          <%= render 'shared/micropost_form' %>
        </section>
      </aside>
      <div class="span8">
        <h3>Micropost Feed</h3>
        <%= render 'shared/feed' %>
      </div>

      <div class="span8">
          <h3>Posts (<%= @user.posts.count %>)</h3>
          <%= render 'shared/post' %>
      </div>

      <%= link_to "Post up", postup_path, class: "btn btn-large btn-primary" %>


      <div style='width: 800px;'>
        <div id="map" style='width: 800px; height: 400px;'></div>
      </div>

      <script type="text/javascript">
        handler = Gmaps.build('Google');
        handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
            markers = handler.addMarkers(<%=raw @hash.to_json %>);
            handler.bounds.extendWith(markers);
            handler.fitMapToBounds();
          });
      </script>

    </div>
上から下に編集

    <div class="row">
      <div class="span3">
        <section>
        <div>
          <h3>Post Feed(<%= @posts.count %>)</h3> //ここに注意
          <%= render 'shared/post' %>
        </div>
        </section>
        <section>
          <%= link_to "Post up", postup_path, class: "btn btn-large btn-primary" %>
        </section>
      </div>

      <div class="span6">
        <div id="map"></div>
      </div>

      <aside class="span3">
        <section>
        <div>
          <h3>Micropost Feed</h3>
          <%= render 'shared/feed' %>
        </div>
        </section>
        <section>
          <%= render 'shared/user_info' %>
        </section>
        <section>
          <%= render 'shared/stats' %>
        </section>
        <section>
          <%= render 'shared/micropost_form' %>
        </section> 
      </aside>


    </div>

      <script type="text/javascript">
        handler = Gmaps.build('Google');
        handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
            markers = handler.addMarkers(<%=raw @hash.to_json %>);
            handler.bounds.extendWith(markers);
            handler.fitMapToBounds();
          });
      </script>


順番を変えたため、(<%= @posts.count %>)に変更しなければ動かなくなった、また_post.html.erbも変える必要がある

app/views/shared/_post.html.erb

    <% if @user.posts.any? %>  //ここ
        <ol class="posts">
        <%= render partial: 'shared/post_item', collection: @post_items %>
        </ol>
        <%= will_paginate @post_items %>
    <% end %>
以下のように編集

    <% if @posts.any? %>   //ここ
        <ol class="posts">
        <%= render partial: 'shared/post_item', collection: @post_items %>
        </ol>
        <%= will_paginate @post_items %>
    <% end %>


app/assts/stylesheets/custom.css.scss
以下のように、widthの指定をなくした、bootstrapでspan指定しているため不要になった

    /* Map */
    #map {
      list-style: none;
      height: 600px;
      margin: 10px 0 0 0;
    }

#### post作成フォームをカスタマイズする
##### 日付をカレンダーから入力できるようにする
[http://amsul.ca/pickadate.js/](http://amsul.ca/pickadate.js/)からダウンロード(2014/09/07 v3.5.3)
解凍して出てきた*pickadate.min.js*をvendor/assets/javascripts/pickadate.jsとして保存。  
app/assets/javascripts/application.jsに以下を追加

    //= require pickadate
    $(document).ready($(function() {
      $('.date').pickadate()
    }));


同様にダウンロードした*pickadate.01.default.css*をvendor/assets/stylesheets/pickadate.cssとして保存  

app/assets/stylesheets/application.cssに以下を追加

     *= require pickadate

app/views/shared/_post_form.html.erbの以下の部分を

    <%= f.datetime_select :date %>
以下に変更

    <%= f.text_field :date, :class => 'date' %>

[参考](http://www.tbn.co.jp/blog/?p=1142)  

#### shared/_post_form.html.erbをパーシャルから元に戻す
_post_form.html.erbはパーシャルというわけではないので、元の位置に移動させる  

mv app/views/shared/_post_form.html.er app/views/posts/


app/views/posts/new.html.erb, edit.html.erbの以下の部分を

    <%= render 'shared/post_form' %>
修正

    <%= render 'post_form' %>

#### posts/index.html.erbの表示をましにする
tableにbootstrapのクラスを指定する

    <table class="table table-striped table-borderd table-condensed">

一番下のNew Postボタンにクラスを指定

    <%= link_to 'New Post', new_post_path, :class=>"class: btn btn-large btn-primary" %>

#### Spotページの作成
登録しているユーザー全員のスポットが一覧で見えるSpotページを作成する  
地図ページを新たに用意する

config/routes.rbに以下を追加(タブあるとSyntax err)

    match '/spot',    to: 'static_pages#spot',    via: 'get'

app/views/layouts/_header.html.erbの以下の行を

          <li><%= link_to "Spot", '#' %></li>
以下のように変更

          <li><%= link_to "Spot", spot_path %></li>

app/views/static_pagesにspot.html.erbを作成し、以下の内容を記述

    <div style='width: 800px;'>
      <div id="map" style='width: 800px; height: 600px;'></div>
    </div>

    <script type="text/javascript">
        handler = Gmaps.build('Google');
        handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
          markers = handler.addMarkers(<%=raw @hash.to_json %>);
          handler.bounds.extendWith(markers);
          handler.fitMapToBounds();
        });
    </script>

static_pages_controller.rbに以下の内容を追加、全postを読み込んで位置情報を元にGoogleMap上にピンを立てる

    def spot
      @posts = Post.all
      @hash = Gmaps4rails.build_markers(@posts) do |post, marker|
        marker.lat post.latitude
        marker.lng post.longitude
        marker.infowindow post.description
        marker.json({title: post.title})
      end
    end

#### postコントローラーを操作できるようにする(delete edit)
---
この区間は不要  
ポストパーシャルに削除リンクを追加する。
_post.html.erbを以下のように編集、

    <li>
      <span class="content"><%= post.content %></span>
      <span class="timestamp">
        Posted <%= time_ago_in_words(post.created_at) %> ago.
      </span>
      <%= render 'shared/_post_delete_link', object: post %>  //ここを追加
    </li>
    
app/views/posts/_post.html.erbは使っていないので削除してもよい
---
    
ポストのアイテムパーシャルに削除リンクを追加する
app/views/shared/_post_item.html.erbを以下のように編集

    <li id="<%= post_item.id %>">
      <%= link_to gravatar_for(post_item.user), post_item.user %>
          <span class="user">
            <%= link_to post_item.user.name, post_item.user %>
          </span>
          <span class="content"><%= post_item.content %></span>
          <span class="timestamp">
            Posted <%= time_ago_in_words(post_item.created_at) %> ago.
          </span>
        <%= render 'shared/post_delete_link', object: post_item %>  //ここを追加
    </li>

app/views/shared/_post_delete_link.html.erbを作成し、以下の内容を記述(_micropost_delete_link.html.erbと同じ内容)

    <% if current_user?(object.user) %>
      <%= link_to "delete", object, method: "delete",
                                       data: { confirm: "You sure?" },
                                       title: object.content %>
    <% end %>

ポストのアイテムパーシャルに編集リンクを追加する
app/views/shared/_post_item.html.erbを以下のように編集

    <li id="<%= post_item.id %>">
      <%= link_to gravatar_for(post_item.user), post_item.user %>
          <span class="user">
            <%= link_to post_item.user.name, post_item.user %>
          </span>
          <span class="content"><%= post_item.content %></span>
          <span class="timestamp">
            Posted <%= time_ago_in_words(post_item.created_at) %> ago.
          </span>
        <%= render 'shared/post_delete_link', object: post_item %>
        <%= render 'shared/post_edit_link', object: post_item %>  //ここを追加
    </li>

app/views/shared/_post_edit_link.html.erbを作成し、以下の内容を記述

    <% if current_user?(object.user) %>
      <%= link_to "edit", edit_post_path(object) %>
    <% end %>


#### Spot画面にpostが表示されるようにする
static_pages_controller.rbを以下のように編集

      def spot
        @posts = Post.all
	    @post_items = Post.all.paginate(page: params[:page]) //ここを追加
        @hash = Gmaps4rails.build_markers(@posts) do |post, marker|
          marker.lat post.latitude
          marker.lng post.longitude
          marker.infowindow post.description
          marker.json({title: post.title})
        end
      end

spot.html.erbを以下のように編集
    <div style='width: 800px;'>
      <div id="map" style='width: 800px; height: 600px;'></div>
    </div>

    <script type="text/javascript">
        handler = Gmaps.build('Google');
        handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
          markers = handler.addMarkers(<%=raw @hash.to_json %>);
          handler.bounds.extendWith(markers);
          handler.fitMapToBounds();
        });
    </script>
上記から下記に
    <div class="row">
      <div class="span3">
        <section>
          <div>
            <h3>post feed(<%= @posts.count %>)</h3>
            <%= render 'shared/post' %>
          </div>
        </section>
        <section>
            <%= link_to "post up", postup_path, class: "btn btn-large btn-primary" %>
        </section>
      </div>

      <div class="span9">
        <div id="map"></div>
      </div>

    </div>

    <script type="text/javascript">
        handler = Gmaps.build('Google');
        handler.buildMap({ provider: {}, internal: {id: 'map'}}, function(){
          markers = handler.addMarkers(<%=raw @hash.to_json %>);
          handler.bounds.extendWith(markers);
          handler.fitMapToBounds();
        });
    </script>

#### DevToolsの404 Not Found(underscore-min.map)エラーを修正
/vendor/assets/javascripts/underscore.jsの以下の行を削除

	//# sourceMappingURL=underscore-min.map
    
#### Google Mapの左側の拡大縮小バーなどの表示がおかしいので直す
assets/stylesheets/custom.css.scssに以下の内容を追加

    #map img { 
	    max-width: none;
    }
    #map label { 
	    width: auto; display:inline; 
	} 

#### 写真アップロード機能の実装
Paperclipを導入  
まずimageMagicが入っていることを確認

	$ which convert

Gemfileに以下を追加

	gem "paperclip", "~> 4.1"

インストール

	$ bundle install
    
Postテーブルに「ファイルの保存用カラムphoto」を追加するためマイグレートファイルを作成

	$ rails g paperclip post photo
	create  db/migrate/20140914154921_add_attachment_photo_to_posts.rb

migrateファイルを表示してみる
    $ cat db/migrate/20140914154921_add_attachment_photo_to_posts.rb 
    class AddAttachmentPhotoToPosts < ActiveRecord::Migration
      def self.up
        change_table :posts do |t|
          t.attachment :photo
        end
      end

      def self.down
        remove_attachment :posts, :photo
      end
    end

migrateする
	$ rake db:migrate

次にPost.rbモデルにphoto用のカラムを記載
	$ vi app/models/post.rb
    
以下のように編集
    class Post < ActiveRecord::Base
    (略)
    has_attached_file :photo, :styles => { medium: "300x300>", thumb: "100x100>" } #attached_fileとして保存、画像サイズを指定
    validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"] #バリデーション
    end
    
今度は 作成と編集画面のERbにファイルアップロード用のinput要素を追加する。  
※ ファイルなどをサーバに送信する場合、HTML的に "multipart" という属性が必要だが、form_forメソッド時のときは自動で追加され、form_tagメソッドの時は自分で記載する。

$ vi app/views/posts/_post_form.html.erb
         ....
    +  <div class="field">
    +     <%= f.file_field :photo %>
    +  </div>
         ....

Rails4からstrong parametersという機能が追加されたため、input属性の "photo" をアップロードできるようにするため、以下を PostsController に追加します。
$ vi app/controllers/posts_controller.rb
       ...
        def post_params
    *      params.require(:picture).permit(:name, :photo)
        end
実際には既にdefされていたので、permitの中に:photoのみ追加した  
  
アップロードした画像を表示するために詳細画面のERbに表示領域を追加
    $ vi app/views/posts/show.html.erb
    
         ...
    +  <p>
    +    <strong>Picture:</strong>
    +    <!--- Modelのstyleで指定した :midium など渡すことでサイズを指定できる -->
    +    <%= image_tag @picture.photo.url(:medium) %> 
    +  </p>
         ...

アップロードファイルの保存先とバリデーション  
保存先はurlとpathで指定し、Validationは次のような項目がある

$ vi app/models/post.rb

    class Post < ActiveRecord::Base
        has_attached_file :post, 
        :styles => { medium: "300x300>", thumb: "100x100>" }, # 先ほどと同じ
        ここはまだ  :url  => "/assets/arts/:id/:style/:basename.:extension", # 画像保存先のURL先
        ここはまだ  :path => "#{Rails.root}/public/assets/arts/:id/:style/:basename.:extension" # サーバ上の画像保存先パス

        ## Validation
        validates_attachment :photo,
         ここはまだ   presence: true,  # ファイルの存在チェック
          less_than: 5.megabytes, # ファイルサイズのチェック
          content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] } # ファイルの拡張しチェック
    end


できたけど、複数画像アップロードしたいので、checkoutしてやめた
---
参考  
[http://ruby-rails.hatenadiary.com/entry/20140716/1405443484](http://ruby-rails.hatenadiary.com/entry/20140716/1405443484)

#### Carrierwaveを使って複数画像をアップロード
Postが複数のPictureを持つことにする  
Gemfileに以下を追加

    gem 'carrierwave'

bundle install

	$ bundle install

アップローダーの作成

	$ rails g uploader Picture
      
写真を保存する用のモデル(post_picture)を作成

    $ rails g model post_picture post_id:integer picture:string
    $ rake db:migrate
  
モデルを編集(post.rb)

    $ vi app/models/post.rb

    class Post < ActiveRecord::Base
      ・・・
      has_many :post_pictures
      accepts_nested_attributes_for :post_pictures
    end    

モデルを編集(post_picture.rb)

    $ vi app/models/post_picture.rb

    class PostPicture < ActiveRecord::Base
      mount_uploader :picture, PictureUploader
      belongs_to :post
    end

コントローラーを編集(post_controller.rb)

    $ vi app/controllers/posts_controller.rb

    def show
       @post_pictures = @post.post_pictures.all
    end

    def new
       @post = Post.new
       @post_picture = @post.post_pictures.build
    end

    def create
      #@post = Post.new(post_params)
      @post = current_user.posts.build(post_params) #自分はこっち

       respond_to do |format|
         if @post.save
           params[:post_pictures]['picture'].each do |a|
              @post_picture = @post.post_pictures.create!(:picture => a, :post_id => @post.id)
           end
           format.html { redirect_to @post, notice: 'Post was successfully created.' }
         else
           format.html { render action: 'new' }
         end
       end
     end

     private
       def post_params
          params.require(:post).permit(:title, post_pictures_attributes: [:id, :post_id, :picture])
       end

フォームを作成

    $ vi app/views/posts/_post_form.html.erb

    <%= form_for(@post, :html => { :multipart => true }) do |f| %>
       <div class="field">
         <%= f.label :title %><br>
         <%= f.text_field :title %>
       </div>

       <%= f.fields_for :post_pictures do |p| %>
         <div class="field">
           <%= p.label :picture %><br>
           <%= p.file_field :picture, :multiple => true, name: "post_pictures[picture][]" %>
         </div>
       <% end %>

       <div class="actions">
         <%= f.submit %>
       </div>
    <% end %>

showを作成

    $ vi app/views/posts/show.html.erb

    <p id="notice"><%= notice %></p>

    <p>
      <strong>Title:</strong>
      <%= @post.title %>
    </p>

    <% @post_pictures.each do |p| %>
      <%= image_tag p.picture_url %>
    <% end %>

    <%= link_to 'Edit', edit_post_path(@post) %> |
    <%= link_to 'Back', posts_path %>

画像アップロード時にサムネイルを作成する  

Gemfileに以下を追加

    gem 'mini_magick', '3.5.0'

    $ bundle install

uploaders/picture_uploader.rbの以下の行のコメントアウトを外す

    # include CarrierWave::MiniMagick

以下のような行があるので、コメントアウトを外す

    #Create different versions of your uploaded files:
    version :thumb do
      process :resize_to_fit => [50, 50]
    end

views/posts/show.html.erbの写真を表示している以下の部分を編集

    <% @post_pictures.each do |p| %>
      <%= image_tag p.picture_url %>
    <% end %>

次のようにする

    <% @post_pictures.each do |p| %>
      <%= image_tag p.picture_url(:thumb) if p.picture? %>
    <% end %>

ここまでをpushしてある



#### Carrierwaveを使って複数画像をアップロード 再び
Postが複数のPictureを持つことにする  
Gemfileに以下を追加

    gem 'carrierwave', '0.10.0'
    gem 'rmagick', '2.13.3'
    gem 'jquery-fileupload-rails', '0.4.1'


bundle install

    $ bundle install

app/assets/javascripts

    $ vi app/assets/javascripts/application.js

    //= require jquery-fileupload

app/assets/stylesheets

    $ vi app/assets/stylesheets/application.css

    *= require jquery.fileupload-ui

アップローダーの作成

  $ rails g uploader Image
      
写真を保存する用のモデル(Picture)を作成

    $ rails g scaffold post_picture post_id:integer image:string
    $ rake db:migrate
  
モデルを編集(post.rb)

    $ vi app/models/post.rb

    class Post < ActiveRecord::Base
      ・・・
      has_many :post_pictures, dependent: :destroy
      accepts_nested_attributes_for :post_pictures, :allow_destroy => true

    end    

モデルを編集(post_picture.rb)

    $ vi app/models/picture.rb

    class PostPicture < ActiveRecord::Base
      belongs_to :post, :polymorphic => true

      include Rails.application.routes.url_helpers

      mount_uploader :image, ImageUploader

      def to_jq_upload
      {
        "name" => read_attribute(image),
        "url" => image.url,
        "size" => image.size,
        "delete_url" => post_picture_path(:id => id),
        "delete_type" => "DELETE"
      }
      end
    end

画像アップロード時にサムネイルを作成する     

uploaders/picture_uploader.rbの以下の行のコメントアウトを外す

    # include CarrierWave::RMagick

以下のような行があるので、コメントアウトを外す

    #Create different versions of your uploaded files:
    version :thumb do
      process :resize_to_fit => [50, 50]
    end


コントローラーを編集(posts_controller.rb)

    $ vi app/controllers/posts_controller.rb

    class PostsController < ApplicationController
      before_action :signed_in_user, only: [:create, :new, :destroy, :edit, :update, :show]
      before_action :set_post, only: [:show, :edit, :update, :destroy]

      # GET /posts
      # GET /posts.json
      def index
        @posts = Post.all
      respond_to do |format|
        format.html
        format.json { render json: @posts }
      end

      end

      # GET /posts/1
      # GET /posts/1.json
      def show
        @post_pictures = @post.post_pictures.all
      end

      # GET /posts/new
      def new
        @post = Post.new
        @post_pictures = @post.post_pictures.build
      end

      # GET /posts/1/edit
      def edit
      end

      # POST /posts
      # POST /posts.json
      def create
        @post = current_user.posts.build(post_params)

        respond_to do |format|
          if @post.save
            flash[:success] = "Post created!"
            #params[:post_pictures]['image'].each do |a|
            #  @post_picture = @post.post_pictures.create!(:image => a, :post_id => @post.id)
           #end
           format.html { redirect_to posts_url, notice: 'Post was successfully created.' }
           #format.json { render action: 'show', status: :created, location: @post }
           format.json { render json: @post, status: :created, location: @post }
          else
            #format.html { render action: 'new' }
            format.html {}
            #format.json { render json: @post.errors, status: :unprocessable_entity }
            format.json {}
          end
        end
      end

      # PATCH/PUT /posts/1
      # PATCH/PUT /posts/1.json
      def update
        respond_to do |format|
          if @post.update(post_params)
            format.html { redirect_to @post, notice: 'Post was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: 'edit' }
            format.json { render json: @post.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /posts/1
      # DELETE /posts/1.json
      def destroy
        @post = Post.find(params[:id])
        @post.destroy

        respond_to do |format|
          format.html { redirect_to posts_url }
          format.json { head :no_content }
        end
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_post
          @post = Post.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def post_params
          params.require(:post).permit(:title, :description, :content, :address, :latitude, :longitude, :user_id, :date, post_pictures_attributes: [:id, :post_id, :image])
        end
    end

コントローラーを編集(post_pictures_controller.rb)

    $ vi app/controllers/post_pictures_controller.rb 

    class PostPicturesController < ApplicationController
      before_action :set_post_picture, only: [:show, :edit, :update, :destroy]

      # GET /post_pictures
      # GET /post_pictures.json
      def index
        @post_pictures = PostPicture.all

        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @post_pictures.map{|p| p.to_jq_upload } }
        end

      end

      # GET /post_pictures/1
      # GET /post_pictures/1.json
      def show
        @post_picture = PostPicture.find(params[:id])

        respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @post_picture }
        end
      end

      # GET /post_pictures/new
      def new
        @post_picture = PostPicture.new

        respond_to do |format|
          format.html # new.html.erb
          format.json { render json: @post_picture }
        end
      end

      # GET /post_pictures/1/edit
      def edit
        @post_picture = PostPicture.find(params[:id])
      end

      # POST /post_pictures
      # POST /post_pictures.json
      def create
        @post = Post.find(params[:post_id])
        @post_picture = PostPicture.new(post_picture_params)

        respond_to do |format|
          if @post_picture.save
            #format.html { redirect_to @post_picture, notice: 'Post picture was successfully created.' }
            format.html { render :json => [@post_picture.to_jq_upload].to_json, :content_type => 'text/html', :layout => false }
            #format.json { render action: 'show', status: :created, location: @post_picture }
            format.json { render :json => {files: [@post_picture.to_jq_upload]}, status: :created, location: @post_picture }
          else
            format.html { render action: 'new' }
            format.json { render json: @post_picture.errors, status: :unprocessable_entity }
           #render :json => [{ :error => "custom_failure "}], :status => 304
          end
        end
      end

      # PATCH/PUT /post_pictures/1
      # PATCH/PUT /post_pictures/1.json
      def update
        respond_to do |format|
          if @post_picture.update(post_picture_params)
            format.html { redirect_to @post_picture, notice: 'Post picture was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: 'edit' }
            format.json { render json: @post_picture.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /post_pictures/1
      # DELETE /post_pictures/1.json
      def destroy
        @post_picture = PostPicture.find(params[:id])
        @post_picture.destroy

    #   render :json => true
        respond_to do |format|
          format.html { redirect_to post_pictures_url }
          format.json { head :no_content }
        end
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_post_picture
          @post_picture = PostPicture.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def post_picture_params
          params.require(:post_picture).permit(:post_id, :image)
        end

    end

フォームを作成

    $ vi app/views/posts/_post_form.html.erb

    <%= form_for @post, :defaults => { :wrapper_html => {:class => 'form-group'}, :input_html => { :class => 'form-control' } }, :html => { :multipart => true,  :id => "fileupload", :class => 'horizontal-form', :role => "form" } do |f| %>

      <% if @post.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(@post.errors.count, "error") %> prohibited this post from being saved:</h2>

          <ul>
          <% @post.errors.full_messages.each do |msg| %>
            <li><%= msg %></li>
          <% end %>
          </ul>
        </div>
      <% end %>

      <div class="field">
        <%= f.label :title %><br>
        <%= f.text_field :title %>
      </div>
      <div class="field">
        <%= f.label :date %><br>
        <%= f.text_field :date, :class => 'date' %>
      </div>
      <div class="field">
        <%= f.label :description %><br>
        <%= f.text_field :description %>
      </div>
      <div class="field">
        <%= f.label :content %><br>
        <%= f.text_area :content %>
      </div>
      <div class="field">
        <%= f.label :address %><br>
        <%= f.text_field :address %>
      </div>
      <div class="field">
        <%= f.label :latitude %><br>
        <%= f.text_field :latitude %>
      </div>
      <div class="field">
        <%= f.label :longitude %><br>
        <%= f.text_field :longitude %>
      </div>
      <div class="field">
        <%= f.label :user_id %><br>
        <%= f.number_field :user_id %>
      </div>

    <!--
       <%= f.fields_for :post_pictures do |p| %>
         <div class="field">
           <%= p.label :picture %><br>
           <%= p.file_field :image, :multiple => true, name: "post_pictures[image][]" %>
         </div>
       <% end %>
    -->

    <div class="row fileupload-buttonbar">
      <div class="col-lg-7">
        <%= fields_for :post_pictures do |a| %>
          <span class="btn btn-success fileinput-button">
            <i class="glyphicon glyphicon-plus"></i>
            <span>Add files...</span>
            <%= a.file_field :image, :name => 'post[post_pictures_attributes][0][image]', :multiple => true %>      
          </span>

          <button type="submit" class="btn btn-primary start">
            <i class="glyphicon glyphicon-upload"></i>
            <span>Start Upload</span>
          </button>

          <button type="reset" class="btn btn-warning cancel">
            <i class="glyphicon glyphicon-ban-circle"></i>
            <span>Cancel Upload</span>
          </button>

          <button type="button" class="btn btn-danger delete">
            <i class="glyphicon glyphicon-trash"></i>
            <span>Delete Upload</span>
          </button>
          <input type="checkbox" class="toggle">

          <% end %>
        </div>

        <div class="col-lg-5">
          <div class="progress progress-success progress-striped active fade">
          <div class="bar" style="width:0%"></div>
        </div>
      </div>

    </div>

    <div class="row fileupload-loading"></div>

      <div class="row">
        <table class="table table-striped">
          <tbody class="files" data-toggle="modal-gallery" data-target="#modal-gallery">
          </tbody>
        </table>
      </div>





      <div class="actions">
        <%= f.submit class: "btn btn-large btn-primary"%>
      </div>

    <% end %>

    <script>
      var fileUploadErrors = {
        maxFileSize: 'File is too big',
        minFileSize: 'File is too small',
        acceptFileTypes: 'Filetype not allowed',
        maxNumberOfFiles: 'Max number of files exceeded',
        uploadedBytes: 'Uploaded bytes exceed file size',
        emptyResult: 'Empty file upload result'
      }; 
    </script>

    <!-- The template to display files available for upload -->
    <script id="template-upload" type="text/x-tmpl">
    {% for (var i=0, file; file=o.files[i]; i++) { %}
      <tr class="template-upload fade">
          <td class="preview"><span class="fade"></span></td>
          <td class="name"><span>{%=file.name%}</span></td>
          <td class="size"><span>{%=o.formatFileSize(file.size)%}</span></td>
            {% if (file.error) { %}
              <td class="error" colspan="2"><span class="label label-important">{%=locale.fileupload.error%}</span> {%=locale.fileupload.errors[file.error] || file.error%}</td>
            {% } else if (o.files.valid && !i) { %}
              <td>
                  <div class="progress progress-success progress-striped active"><div class="bar" style="width:0%;"></div></div>
              </td>
              <td class="start">{% if (!o.options.autoUpload) { %}
                  <button class="btn btn-primary">
                      <i class="icon-upload icon-white"></i>
                      <span>{%=locale.fileupload.start%}</span>
                  </button>
              {% } %}</td>
          {% } else { %}
              <td colspan="2"></td>
          {% } %}
          <td class="cancel">{% if (!i) { %}
              <button class="btn btn-warning">
                  <i class="icon-ban-circle icon-white"></i>
                  <span>{%=locale.fileupload.cancel%}</span>
              </button>
          {% } %}</td>
      </tr>
    {% } %}
    </script>
    <!-- The template to display files available for download -->
    <script id="template-download" type="text/x-tmpl">
      {% for (var i=0, file; file=o.files[i]; i++) { %}
      <tr class="template-download fade">
        {% if (file.error) { %}
          <td></td>
          <td class="name"><span>{%=file.name%}</span></td>
          <td class="size"><span>{%=o.formatFileSize(file.size)%}</span></td>
          <td class="error" colspan="2"><span class="label label-important">{%=locale.fileupload.error%}</span> {%=locale.fileupload.errors[file.error] || file.error%}</td>
          {% } else { %}
              <td class="preview">{% if (file.thumbnail_url) { %}
                  <a href="{%=file.url%}" title="{%=file.name%}" rel="gallery" download="{%=file.name%}"><img src="{%=file.thumbnail_url%}"></a>
              {% } %}</td>
              <td class="name">
                  <a href="{%=file.url%}" title="{%=file.name%}" rel="{%=file.thumbnail_url&&'gallery'%}" download="{%=file.name%}">{%=file.name%}</a>
              </td>
              <td class="size"><span>{%=o.formatFileSize(file.size)%}</span></td>
              <td colspan="2"></td>
          {% } %}
          <td class="delete">
              <button class="btn btn-danger" data-type="{%=file.delete_type%}" data-url="{%=file.delete_url%}">
                  <i class="icon-trash icon-white"></i>
                  <span>{%=locale.fileupload.destroy%}</span>
              </button>
              <input type="checkbox" name="delete" value="1">
          </td>
      </tr>
    {% } %}
    </script>

    <script type="text/javascript" charset="utf-8">
      $(function () {
        // Initialize the jQuery File Upload widget:
        $('#fileupload').fileupload({
          sequentialUploads: true,
        });

          // Load existing files:
          $.getJSON($('#fileupload').prop('action'), function (files) {
            var fu = $('#fileupload').data('blueimpFileupload'),
            template;
            fu._adjustMaxNumberOfFiles(-files.length);
            console.log(files);
            template = fu._renderDownload(files)
            .appendTo($('#fileupload .files'));
            // Force reflow:
            fu._reflow = fu._transition && template.length &&
            template[0].offsetWidth;
            template.addClass('in');
            $('#loading').remove();
            });


       });
     </script>


showを編集

    $ vi app/views/posts/show.html.erb

    <p id="notice"><%= notice %></p>

    <p>
      <strong>Title:</strong>
      <%= @post.title %>
    </p>

    //これを追加
    <strong>Picture:</strong><br/>
    <% @post_pictures.each do |p| %>
      <%= image_tag p.image_url(:thumb).to_s %>
      <%= render 'shared/post_picture_delete_link', object: p %></br>
    <% end %>

    <%= link_to 'Edit', edit_post_path(@post) %> |
    <%= link_to 'Back', posts_path %>


ここまでをpushしてある

#### startboostrapを適用して、Home画面をリニューアル

ここからダウンロード[https://github.com/IronSummitMedia/startbootstrap](https://github.com/IronSummitMedia/startbootstrap)



#### テスト用データベースのリセット方法
	rake db:reset
	rake db:populate
	rake test:prepare

# Gitの覚書
 mkdir template_app
 cd template_app/
 git init
 git add .
 git commit -m "Initialize repository"
 git remote add origin https://github.com/hoge/template_app.git
 push -u origin master
 git push -u origin master
編集
 git commit -m "Re.copy"
 git push

#### gitコミットまで
    $ git add .
    $ git commit -m "Finish static pages"
    次にmasterブランチに移動し、1.3.5と同じ要領で差分をマージします。
    $ git checkout master
    $ git merge static-pages
    $ git push

#### Herokuに上げる
    heroku create
    git push heroku master
    heroku run rake db:migrate
    heroku run rake db:populate
    heroku run rake db:prepare
