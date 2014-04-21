require 'test_helper'

class ResourcePersistenceTest < ActiveSupport::TestCase

  GREETING_ETAG = '"0ce56d0a6e9baa0c5d170001592c9b9c65d19276"'
  GREETING_LAST_MODIFIED = 1391848200
  GREETING_SIZE = 5
  GREETING_FINGERPRINT = 'Wab4pWDcin+Z9HBXC8wQD1DkFZIvv3GievNMVjDPIzo='

  DOG_ETAG = '"cee1cac995540c33e06d792e077297bd31e7e504"'
  DOG_LAST_MODIFIED = 1391848200
  DOG_SIZE = 20997
  DOG_SIGNATURE = 'siNHt2UDgfCAwhga/x8nQm3HKXKSrVrLk1U+GtyvYrA='

  def test_resource_attribs
    Timecop.freeze(now) do
      #greeting = Fetchery::Resource.create(url: Dummy::test_file(name: 'greeting.png'))
      greeting.fetch
      assert_equal 200, greeting.resource.status_code
      assert_equal GREETING_ETAG, greeting.resource.etag
      assert_equal GREETING_SIZE, greeting.resource.size
      assert_equal GREETING_FINGERPRINT, greeting.resource.fingerprint
      assert_equal 0, greeting.resource.fail_count
      assert_equal now, greeting.resource.tried_at
      assert_equal now, greeting.resource.fetched_at
      assert_equal now+1.day, greeting.resource.next_try_after
    end
  end

  def test_blank_resource_attribs
    greeting.url = Dummy::test_file(etag: '_', last_modified: '_')
    greeting.fetch
    assert_equal 200, greeting.resource.status_code
    assert_equal nil, greeting.resource.etag
    assert_equal nil, greeting.resource.last_modified
  end

  def test_blank_resource_attribs
    Timecop.freeze(now) do
      greeting.url = Dummy::test_file(name: 'does-not-exist')
      greeting.fetch
      assert_equal 404, greeting.resource.status_code
      assert_equal 1, greeting.resource.fail_count
      assert_equal now, greeting.resource.tried_at
      assert_equal now, greeting.resource.failed_at
      assert_equal now+1.hour, greeting.resource.next_try_after
      greeting.fetch
      assert_equal 2, greeting.resource.fail_count
    end
  end

end
