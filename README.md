# README

## 前言
在 Rails 实现用户注册和登录功能是非常方便的，比如可以使用 Devise 这类实现了完整功能的 gem 扩展包。

但是使用gem扩展包的话可能不太好自定义。
所以还是需要熟悉在Rails中实现用户注册和登录的写法。

这个小demo实现了注册，登录，登出，显示用户信息，强制登录访问指定页面的功能

## 简单介绍
#### [具体内容请参照相关链接](#相关链接)

1.Add bcrypt (~> 3.1.7) to Gemfile to use has_secure_password
```xml
gem 'bcrypt', '~> 3.1.7'
```
```shell
bundle install
```
2.application.html.erb被包裹在我们网站的每个页面上，页眉，导航或页脚的编辑可以只编辑此文件

3.user
```shell
rails g model user name email password_digest
```
```ruby
#app/models/user.rb
has_secure_password

# Verify that email field is not blank and that it doesn't already exist in the db (prevents duplicates):
validates :email, presence: true, uniqueness: true

```
```shell
rails g controller users
```
```ruby
#app/controllers/users_controller.rb:
@user = User.new(user_params)

#email以小写形式存储，避免重复和区分大小写
@user.email.downcase!

if @user.save
      flash[:notice] = "Account created successfully!"
      redirect_to root_path
    else
      flash.now.alert = "Oops, couldn't create account. Please make sure you are using a valid email and password and try again."
      render :new
```

4.session
```shell
rails g controller sessions
```
```ruby
#app/controllers/sessions_controller.rb

user = User.find_by(email: params[:login][:email].downcase)

if user && user.authenticate(params[:login][:password]) 
session[:user_id] = user.id.to_s
      redirect_to root_path, notice: 'Successfully logged in!'

flash.now.alert = "Incorrect email or password, try again."
      render :new

 def destroy
    # delete the saved user_id key/value from the cookie:
    session.delete(:user_id)
    redirect_to login_path, notice: "Logged out!"
  end
```
5.current_user
```ruby
helper_method :current_user

def current_user
    # Look up the current user based on user_id in the session cookie:
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

#app/views/layouts/application.html.erb

<% if current_user %>
      <!-- current_user will return true if a user is logged in -->
      <%= "Logged in as #{current_user.email}" %> | <%= link_to 'Home', root_path %> | <%= link_to 'Log Out', logout_path, method: :delete %>
    <% else %>
      <!-- not logged in -->
      <%= link_to 'Home', root_path %> | <%= link_to 'Log In', login_path %> or <%= link_to 'Sign Up', new_user_path %>
    <% end %>
```

6.Authorization (restricting access to pages)
```ruby
#app/controllers/application_controller.rb

# authroize method redirects user to login page if not logged in:
    def authorize
      redirect_to login_path, alert: 'You must be logged in to access this page.' if current_user.nil?
    end
```
```
rails g controller pages secret
```
```ruby
#app/controllers/pages_controller.rb

before_action :authorize, only: [:secret]
```


## 相关链接
[Simple Authentication in Rails 6 with has_secure_password](https://gist.github.com/iscott/4618dc0c85acb3daa5c26641d8be8d0d)

[ActiveModel::SecurePassword::ClassMethods](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html)
