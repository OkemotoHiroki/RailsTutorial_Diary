require "test_helper"

class GoogleOauthControllerTest < ActionDispatch::IntegrationTest
  test "should get start" do
    get google_oauth_start_url
    assert_response :redirect
  end

  test "should get callback" do
    fake_token = Struct.new(:token, :refresh_token).new("token123", "refresh123")

    GoogleOauthService.stub(:exchange, fake_token) do
      get google_oauth_callback_url, params: { code: "test_code" }

      assert_response :redirect
      assert_equal "token123", session[:access_token]
    end
  end
end
