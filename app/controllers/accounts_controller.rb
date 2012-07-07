class AccountsController < ApplicationController
  skip_before_filter :check_current_user, :only => [:new, :create, :activate]

  filter_resource_access :context => :users,
                         :new => [[:new, :new_account], [:create, :new_account]],
                         :member => [[:activate, :activate_account], [:show, :show_account], [:edit, :edit_account], [:update, :edit_account]],
                         :additional_member => [[:edit_password, :edit_password_account], [:update_password, :edit_password_account]]
  def new
  end

  def create
    @user.role = Role::MANAGER
    @user.active = true
    if @user.save
      flash[:notice] = t('user.flashes.created')

      config_opentok

      #@new_room = Room.new(:name => @user.company.url_base, :session_id =>"1_MX4xMjMyMDgxfjcwLjQyLjQ3Ljc4fjIwMTItMDItMDggMDc6MDI6MTQuNjYxMjI5KzAwOjAwfjAuMDEwNjcwMTQzMTE1Nn4", :public => true)
      session = @opentok.create_session request.remote_addr
      @new_room = Room.new(:name => @user.company.url_base, :session_id =>session.session_id, :public => true)
      @new_room.company = @user.company
      @new_room.save

      redirect_to company_path
    else
      flash[:error] = t('user.flashes.create_error')
      render 'pages/main', :layout => 'main'
    end
  end

  def show
  end

  def update
     @user.update_attributes(:first_name => params[:user][:first_name],
                             :last_name => params[:user][:last_name],
                             :telephone => params[:user][:telephone],
                             :address => params[:user][:address])
     @user.update_attribute(:avatar, params[:user][:avatar])

     if (params[:change_password])
       if (params[:user][:password] == params[:user][:password_confirmation])
         @user.update_attribute(:password,params[:user][:new_password])
         flash[:notice] = t('user.flashes.change_password')

         @user_session = UserSession.find
         @user_session.destroy

         redirect_to application_root_path
       else
         flash[:error] = t('user.flashes.change_password_error')
         redirect_to account_path
       end
     else
       redirect_to account_path
     end
  end

  def activate
    @user = User.find_using_perishable_token(params[:activation_code], 1.week) || (raise Exception)

    raise Exception if @user.active?

    if @user.activate!
      UserSession.create(@user, false)
      redirect_to account_url
    else
      render :action => :new
    end
  end

  protected

  def load_account
    @user = self.current_user
  end

   private
	  def config_opentok
	    if @opentok.nil?
	      @opentok = OpenTok::OpenTokSDK.new(11739502, "75d020096690199bd0fd54522a66cd0bd5a2a145", :api_url =>'https://api.opentok.com/hl')
	    end
    end
end
