require "sinatra"
require "sinatra/reloader"
require "sinatra/cookies"
require "pry"

require "pg"
enable :sessions
# https://knowledge-blog.net/articles/31より
# _methodのおまじないを使えるようにする
enable :method_override

client = PG::connect(
  :host => "localhost",
  :user => ENV.fetch("USER", "masaki"),
  :password => "",
  :dbname => "shop",
)

# プロダクト一覧
get "/products" do
  return erb :products
end

post "/products" do
end
# プロダクト一覧

# サインアップ
get "/signup" do
  return erb :signup
end

post "/signup" do
  name = params[:name]
  zipcode = params[:zipcode]
  phonenum = params[:phonenum]
  address = params[:address]
  email = params[:email]
  password = params[:password]

  client.exec_params(
    "INSERT INTO users (name, zipcode, address, phonenum, email, password) VALUES ($1, $2, $3, $4, $5, $6)", [name, zipcode, phonenum, address, email, password]
  )

  user = client.exec_params(
    "SELECT * from users WHERE email = $1 AND password = $2", [email, password]
  ).to_a.first

  session[:user] = user

  return redirect "/products"
end
# サインアップ

# ログイン
get "/login" do
  return erb :login
end

post "/login" do
  email = params[:email]
  password = params[:password]
  user = client.exec_params("SELECT * FROM users WHERE email = '#{email}' AND password = '#{password}'").to_a.first

  if user.nil?
    return erb :login
  else
    session[:user] = user
    return redirect "/products"
  end
end
# ログイン

# ログアウト
# delete '/logout' do
#   session[:user] = nil
#   return redirect '/products'
# end

# https://knowledge-blog.net/articles/31より
delete "/logout" do
  session[:user] = nil
  session.clear

  redirect "/products"
end
# ログアウト

# アイテム
get "/item" do
  @products = client.exec_params("SELECT * from products").to_a

  # progate ruby復習より
  # class Item
  #   attr_accerssor:name
  #   attr_accerssor:price

  #   def initialize(name:, price:)
  # self.name = "ブーケA"
  # self.price = 3,000
  #   self.name = name
  #   self.price = price
  # end

  # def info
  # puts "ブーケAの詳細"
  # return "#{itemName}の詳細"
  #   return "#{self.name}の詳細 #{self.price}円"
  # end

  # def get_total_price(count)
  #   total_price = self.price * count
  # if count >= 3
  #   total_price -= 100
  # end
  #   return total_price
  # end

  # end
  # item1 = Item.new
  # item1.name = ブーケA
  # item1.price = 3,000
  # puts item1.info("ブーケA")
  # puts item1.info # selfより initializeも

  # item2 = Item.new(name:"ブーケB", price:5,000)
  # puts item2.info

  # progate ruby復習より ここまで

  return erb :item
end
# アイテム

# カート
get "/cart" do
  return erb :cart
end
# カート
