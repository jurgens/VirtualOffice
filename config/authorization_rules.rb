authorization do

  ## fake roles

  role :public do
    has_permission_on :static, :to => :home
    has_permission_on :user_sessions, :to => [:activate]
  end

  role :guest do
    includes :public

    has_permission_on :user_sessions, :to => [:new, :create, :activate]
    # has_permission_on :user_sessions, :to => :activate
    has_permission_on :users, :to => :new_account
    has_permission_on :users, :to => :create_account do
      if_permitted_to :new_account
    has_permission_on :users, :to => :manage
    end

    has_permission_on :user_sessions, :to => [:new, :create, :activate, :create_demo]
  end

  role :authorized do
    includes :public

    has_permission_on :user_sessions, :to => [:new, :destroy]

    has_permission_on :users, :to => [:show_account, :edit_account] do
      if_attribute :id => is {user.id}
    end
    has_permission_on :users, :to => :update_account do
      if_permitted_to :edit_account
      #if_attribute :active => is_not_changed
    end
  end

  ## real roles

  role :admin do
    includes :authorized
  end

  role :manager do
    includes :authorized
    has_permission_on :users, :to => [:new_account, :show_account]
    has_permission_on :companies, :to => [:show, :edit, :update, :workers]
    has_permission_on :users, :to => :manage
    has_permission_on :events, :to => [:manage,:create, :update, :delete]
  end

  role :worker do
    includes :authorized
    has_permission_on :users, :to => [:new_account, :show_account]
    has_permission_on :companies, :to => [:show, :edit, :update, :workers]
    has_permission_on :users, :to => :manage
    has_permission_on :events, :to => [:manage,:create, :update, :delete]
  end

end

privileges do
  privilege :manage, :includes => [:index, :show, :new, :create, :edit, :destroy]

  privilege :new_account, :users, :includes => :activate_account
  privilege :edit_account, :users, :includes => :edit_password_account
  privilege :update_account, :users, :includes => :update_password_account

end
