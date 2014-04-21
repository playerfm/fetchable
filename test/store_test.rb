require_relative './test_helper'

class StoreTest < ActiveSupport::TestCase

  GREETING_CONTENT = 'ohai'

  def test_first_fetch_creates_resource
    Fetchery::Resource.settings.store = Fetchery::Store::FileStore.new(
      folder: '/tmp/testing',
      name_prefix: 'doco' 
    )
    greeting.fetch
    expected_path = "/tmp/testing/doco#{Fetchery::Util.encode greeting.id}.txt"
    assert File.exist?(expected_path), "no file at #{expected_path}"
    assert_equal GREETING_CONTENT, open(expected_path).read.chomp
  end

end
