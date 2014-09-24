require "spec_helper"

describe PostPicturesController do
  describe "routing" do

    it "routes to #index" do
      get("/post_pictures").should route_to("post_pictures#index")
    end

    it "routes to #new" do
      get("/post_pictures/new").should route_to("post_pictures#new")
    end

    it "routes to #show" do
      get("/post_pictures/1").should route_to("post_pictures#show", :id => "1")
    end

    it "routes to #edit" do
      get("/post_pictures/1/edit").should route_to("post_pictures#edit", :id => "1")
    end

    it "routes to #create" do
      post("/post_pictures").should route_to("post_pictures#create")
    end

    it "routes to #update" do
      put("/post_pictures/1").should route_to("post_pictures#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/post_pictures/1").should route_to("post_pictures#destroy", :id => "1")
    end

  end
end
