require 'test_helper'

class MatchControllerTest < ActionDispatch::IntegrationTest
  test "should get match" do
    get match_match_url
    assert_response :success
  end

end
