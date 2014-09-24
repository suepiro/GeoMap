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
