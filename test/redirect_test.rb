require_relative './test_helper'

class RedirectTest < ActiveSupport::TestCase

  def test_redirect_chain_is_followed_and_captured
    dog.url = Dummy::test_file(name: 'greeting.txt', redirect: '2')
    dog.fetch
    assert_equal 200, dog.resource.status_code
    assert_equal Dummy::test_file(name: 'greeting.txt', redirect: '0'), dog.resource.redirected_to
  end

  def test_relative_redirect
    dog.url = Dummy::test_file(name: 'greeting.txt', relative_redirect: '2')
    dog.fetch
    assert_equal 200, dog.resource.status_code
    assert_equal Dummy::test_file(name: 'greeting.txt', relative_redirect: '0'), dog.resource.redirected_to
  end

end
