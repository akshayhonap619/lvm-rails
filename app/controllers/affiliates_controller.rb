class AffiliatesController < ApplicationController
  before_action :set_affiliate, only: [:show, :edit, :update, :destroy]
  before_action :ensure_admin!

  add_breadcrumb 'Home', :root_path

  # GET /affiliates
  def index
    add_breadcrumb 'Affiliates'

    @new_button = {
      text: 'Create New Affiliate',
      url: new_affiliate_path
    }
    @clickable_rows = true
    @page_title = 'Affiliates'
    @models = Affiliate.all
    @headers = [
      'Name',
      'Address',
      'Phone Number',
      'Email',
      'Website',
      'Twitter',
      'Tags'
    ]
    @columns = [
      'name',
      'full_address',
      'phone_number',
      'email',
      'website',
      'twitter',
      'tags'
    ]
  end

  # GET /affiliates/1
  def show
    add_breadcrumb 'Affiliates', affiliates_path
    add_breadcrumb @affiliate.name
  end

  # GET /affiliates/new
  def new
    add_breadcrumb 'Affiliates', affiliates_path
    add_breadcrumb 'New Affiliate'

    @affiliate = Affiliate.new
  end

  # GET /affiliates/1/edit
  def edit
    add_breadcrumb 'Affiliates', affiliates_path
    add_breadcrumb @affiliate.name, affiliate_path(@affiliate)
    add_breadcrumb 'Edit'
  end

  # POST /affiliates
  def create
    @affiliate = Affiliate.new(affiliate_params)

    if @affiliate.save
      redirect_to @affiliate, notice: 'Affiliate was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /affiliates/1
  def update
    if @affiliate.update(affiliate_params)
      redirect_to @affiliate, notice: 'Affiliate was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /affiliates/1
  def destroy
    @affiliate.destroy
    redirect_to affiliates_url, notice: 'Affiliate was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_affiliate
    @affiliate = Affiliate.find(params[:id])
  end

  def affiliate_params
    params.require(:affiliate).permit(:name, :address, :phone_number,
                                      :email, :website, :twitter, :zip,
                                      :city, :state, :tags)
  end
end
