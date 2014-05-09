require_relative './test_helper'

class InheritanceTest < ActiveSupport::TestCase

  def test_subclass_is_fetchable
    quote_url = Dummy::test_file(name: 'aristotle.txt', last_modified: '_', etag: '_')
    quote = HistoricalQuote.new(url: quote_url)
    quote.expects(:handle_historical_quote)
    quote.fetch
    assert_equal 200, quote.status_code
  end

end
