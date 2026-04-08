require "test_helper"

class GoogleOauthControllerTest < ActionDispatch::IntegrationTest
  test "should get start" do
    get google_oauth_start_url
    assert_response :success
  end

  test "should get callback" do
    get google_oauth_callback_url
    assert_response :success
  end
end
