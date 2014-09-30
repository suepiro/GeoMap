class PostsController < ApplicationController
  before_action :signed_in_user, only: [:create, :new, :destroy, :edit, :update, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
    respond_to do |format|
      format.html
      #format.json { render json: @posts }
    end
    puts "=============="
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post_pictures = @post.post_pictures.all

    postNo = params[:id] #postの通番
    postNo = postNo.to_i
    @posts = Post.find(:all, :conditions => { :id => postNo })
    @post_picture = @posts[0].post_pictures.all

    puts @posts.length
    puts @post_picture.length

    respond_to do |format|
      format.html
      format.json { render json: @post_picture }
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
    @post_pictures = @post.post_pictures.build
  end

  # GET /posts/1/edit
  def edit
    @post_pictures = @post.post_pictures.all
    @posts = Post.all

    puts "suehiro debug"
    @post_pictures.each do |p|
      puts p.image
    end
    puts "eeeeeeeeeeeeeeeeeeeeeee "

    #respond_to do |format|
      #format.html
      #format.json { render json: @posts }
    #end

  end

  # POST /posts
  # POST /posts.json
  def create
    postNo = params["post"]["post_id"]    #postの通番
    postNo = postNo.to_i + 1
    #userID = current_user.id
    if Post.exists?(postNo) == false
      @post = current_user.posts.build(post_params)
    else
      params["post"]["user_id"] = current_user.id
      @post = Post.find(postNo)
      @post.update(post_params)
    end

    respond_to do |format|
      if @post.save
        flash[:success] = "Post created!"
        #params[:post_pictures]['image'].each do |a|
        #  @post_picture = @post.post_pictures.create!(:image => a, :post_id => @post.id)
       #end
       format.html { redirect_to posts_url, notice: 'Post was successfully created.' }  #createメソッドがhtmlで呼び出された場合
       #format.json { render action: 'show', status: :created, location: @post }
       format.json { render json: @post, status: :created, location: @post }            #createメソッドがjsonから呼び出された場合
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
