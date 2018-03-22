class OwnersController < ApplicationController
  # A callback to set up an @owner object to work with 
  before_action :set_owner, only: [:show, :edit, :update, :destroy]
  before_action :check_login
  authorize_resource

  def index
    # finding all the active owners and paginating that list (will_paginate)
    @active_owners = Owner.active.alphabetical.paginate(page: params[:page]).per_page(15)
  end

  def show
    # authorize! :show, @owner
    # get all the pets for this owner
    @current_pets = @owner.pets.alphabetical.active.to_a
  end

  def new
    @owner = Owner.new
  end

  def edit
  end

  def create
    @owner = Owner.new(owner_params)
    @user = User.new(user_params)
    @user.role = "owner"
    if @user.save
      @owner.user_id = @user.id
      if @owner.save
        # if saved to database
        flash[:notice] = "Successfully created #{@owner.proper_name}."
        redirect_to owner_path(@owner) # go to show owner page
      else
        # return to the 'new' form
        render action: 'new'
      end
    else
      render action: 'new'
    end
  end

  def update
    if @owner.update_attributes(owner_params)
      flash[:notice] = "Successfully updated #{@owner.proper_name}."
      redirect_to @owner
    else
      render action: 'edit'
    end
  end

  def destroy
    if @owner.destroy
      redirect_to owners_url, notice: "Successfully removed #{@owner.proper_name} from the PATS system."
    else
      @current_pets = @owner.pets.alphabetical.active.to_a
      render action: 'show'
    end
  end

  private
    def set_owner
      @owner = Owner.find(params[:id])
    end

    def owner_params
      params.require(:owner).permit(:first_name, :last_name, :street, :city, :state, :zip, :phone, :email, :active, :username, :password, :password_confirmation)
    end

    def user_params
      params.require(:owner).permit(:first_name, :last_name, :active, :username, :password, :password_confirmation)
    end

end
