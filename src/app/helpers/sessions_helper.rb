module SessionsHelper
  # ブラウザにセッションを作成する = 渡されたユーザでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  def remember(user)
    # attr_accessorのremember_tokenをインスタンスメソッドrememberで初期化
    # remember_tokenのハッシュ値をrememer_digestとしてデータベースに保存
    user.remember
    # cookiesにはuser.idとremember_tokenの両方を保存
    # user_idを暗号化して保存
    cookies.permanent.encrypted[:user_id] = user.id
    # remember_tokenも保存
    cookies.permanent[:remember_token] = user.remember_token
  end


  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    # ユーザーIDにユーザーIDのセッションを代入した結果,ユーザーIDのセッションが存在すれば
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember,cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # 渡されたユーザーがカレントユーザーであればtrueを返す
  def current_user?(user)
    user && user == current_user
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  def forget(user)
    # dbのremember_digestをnilに更新
    user.forget
    # coookiesのuser_idとremember_tokenを削除
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    # 永続的セッションを破棄
    forget(current_user)
    # 一時セッションを破棄
    session.delete(:user_id)
    @current_user = nil
  end

  # 記憶したURL（もしくはデフォルト値）にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
