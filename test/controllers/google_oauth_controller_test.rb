require "test_helper"

class GoogleOauthControllerTest < ActionDispatch::IntegrationTest
  test "should get start" do
    get google_oauth_start_url
    assert_response :redirect
  end

  test "should get callback" do
    fake_token = Struct.new(:token, :refresh_token)
                        .new("token123", "refresh123")

    GoogleOauthService.singleton_class.class_eval do
      define_method(:exchange) do |_code, _redirect_uri|
        fake_token
      end
    end

    get google_oauth_callback_url, params: { code: "test" }

    assert_response :redirect
    assert_equal "token123", session[:access_token]
    assert_equal "refresh123", session[:refresh_token]
  end
end
