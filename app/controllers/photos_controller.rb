class PhotosController < ApplicationController

  def index
    respond_to do |format|
      format.html do
        @photos = Photo.all.where(checked:true).order(created_at: :desc).limit(9)
      end
      format.json do
        @photos = Photo.all.where(checked:true).order(created_at: :desc).limit(9)
        render json: @photos.to_json
      end
    end
  end

end
