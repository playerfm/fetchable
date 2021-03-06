require 'test_helper'

# This is the main module test checking typical properties and regular use
# cases

class FetchableTest < ActiveSupport::TestCase

  GREETING_ETAG = '"0ce56d0a6e9baa0c5d170001592c9b9c65d19276"'
  GREETING_LAST_MODIFIED = 1391848200
  GREETING_SIZE = 5
  GREETING_FINGERPRINT = 'Wab4pWDcin+Z9HBXC8wQD1DkFZIvv3GievNMVjDPIzo='

  DOG_ETAG = '"cee1cac995540c33e06d792e077297bd31e7e504"'
  DOG_LAST_MODIFIED = 1391848200
  DOG_SIZE = 20997
  DOG_FINGERPRINT = 'siNHt2UDgfCAwhga/x8nQm3HKXKSrVrLk1U+GtyvYrA='

  FAREWELL_ETAG = '"49554c66412893f10e5492a3e4d9571413cec578"'
  FAREWELL_LAST_MODIFIED = '"49554c66412893f10e5492a3e4d9571413cec578"'
  FAREWELL_SIZE = 5
  FAREWELL_FINGERPRINT = 'bwN48hpJX1wTJHMX0Vjp1R2kWlv2j8LzZuRQ3q/cgwI='

  def test_attribs
    Timecop.freeze(now) do
      farewell = Document.create(url: Dummy::test_file(name: 'farewell.txt'))
      farewell.fetch
      farewell.reload
      assert_equal 200, farewell.status_code
      assert_equal FAREWELL_ETAG, farewell.etag
      assert_equal FAREWELL_SIZE, farewell.size
      assert_equal FAREWELL_FINGERPRINT, farewell.fingerprint
      assert_equal 'text/plain', farewell.received_content_type
      assert_equal 'text/plain', farewell.content_type
      assert_equal 0, farewell.fetch_fail_count
      assert_equal now, farewell.fetch_tried_at
      assert_equal now, farewell.fetch_succeeded_at
    end
  end

  def test_suppress_saving
      farewell = Document.create(url: Dummy::test_file(name: 'farewell.txt'))
      assert_nil farewell.status_code
      farewell.fetch save: false
      assert_equal 200, farewell.status_code
      farewell.reload
      assert_nil farewell.status_code
  end

  def test_validate_url
    assert greeting.valid?
    greeting.url = 'not a url'
    assert_not_nil greeting.errors[:url]
  end

  def test_infer_filetype
    farewell = Document.create(url: Dummy::test_file(name: 'farewell.txt', type: 'image/gif'))
    farewell.fetch
    assert_equal 'image/gif', farewell.received_content_type
    assert_equal 'application/x-httpd-php', farewell.inferred_content_type
    assert_equal 'image/gif', farewell.content_type
  end

  def test_change_tracking

    start = now

    Timecop.freeze(start) do
      greeting.fetch
      assert_equal start, greeting.fetch_changed_at
    end

    Timecop.freeze(start+5.minutes) do
      greeting.etag = greeting.last_modified = nil
      assert_equal start, greeting.fetch_changed_at
    end

    Timecop.freeze(start+10.minutes) do
      greeting.url = Dummy::test_file(name: 'farewell.txt')
      greeting.etag = greeting.last_modified = nil
      greeting.fetch
      assert_equal start+10.minutes, greeting.fetch_changed_at
    end

  end

  def test_attribs_when_unfetched
    greeting.url = Dummy::test_file(etag: '_', last_modified: '_')
    greeting.fetch
    assert_equal 200, greeting.status_code
    assert_equal nil, greeting.etag
    assert_equal nil, greeting.last_modified
  end

end
