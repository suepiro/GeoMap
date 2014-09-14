class StaticPagesController < ApplicationController
  
  def home
  	if signed_in?
	  	@micropost = current_user.microposts.build
	  	@feed_items = current_user.feed.paginate(page: params[:page])
      @posts = current_user.posts.paginate(page: params[:page])
      @post_items = current_user.posts.paginate(page: params[:page])
      @hash = Gmaps4rails.build_markers(@posts) do |post, marker|
        marker.lat post.latitude
        marker.lng post.longitude
        marker.infowindow post.description
        marker.json({title: post.title})
      end
  	end
  end

  def help
  end

  def about
  end

  def contact
  end

  def spot
    @posts = Post.all
    @post_items = Post.all.paginate(page: params[:page])
    @hash = Gmaps4rails.build_markers(@posts) do |post, marker|
      marker.lat post.latitude
      marker.lng post.longitude
      marker.infowindow post.description
      marker.json({title: post.title})
    end
  end

end