### Fetchable

This Rails plugin helps you sync ActiveRecords with remote resources. It's
convenient for writing bots, scrapers, and the like.

Notes:

* Not complete yet - the examples below are partly a roadmap and won't all
  work.
* It's my first Rails gem, so I'm learning as I go here.

### Basic usage

Fetchable retains call results for you.

    class Image < ActiveRecord::Base
      include Fetchable
    end

    image = image.create(url: 'http://upload.wikimedia.org/wikipedia/en/b/bc/Wiki.png')
    image.fetch
    puts image.resource.size # 12345
    puts image.live_resource? # true

### Re-fetch example

Fetchable conserves energy. HTTP "memento" standards (eTags and timestamp) are
leveraged to avoid unnecessarily repeating stuff.

    image.fetch # first fetch creates a resource record
    image.fetch # second re-fetch only does a full download if the image changed

### Callback example

Fetchable calls your ActiveRecord when stuff happens, just like the usual
ActiveRecord callbacks.

    class Image < ActiveRecord::Base

      include Fetchable

      before_fetch :cancel_if_server_too_busy
      after_new_fetch :save_image_dimensions
      fetch_error :report_problem
      after_redirect :save_url_alias
      after_fetch :log_fetch

    end

### Fetch management

Fetchable helps you schedule recurring fetches.

    class Image
      refetching({
        repeat: 1.day,       # minimum repeat wait after success
        retry: 1.hour,       # minimum repeat after error (decays exponentially)
        fresh_repeat: 1.week # minimum "fresh" refetch after success (ie ignore mementos)
        fresh_retry: 1.day   # minimum "fresh" retry after error (ie ignore mementos)
      })
    end

    Image.due_for_repeat_fetch.each { |i| i.fetch(hard: true) }

### Other Features (not doc'd yet)

* Retain resource body, either on file system or in DB

### Future plans

Track permanent redirects in another table

Possible options in the future:
* Migration support
* changed\_at: Recognise same content transmission via fingerprint (pseudo-304)
* Enforce unique URLs (and maybe canonical URLs)

### Setup

Create a "resources" table. For now, [see this
example](https://github.com/playerfm/fetchable/blob/master/test/dummy/db/migrate/01_create_resources.rb).

For each of your fetchable classes, add a add an integer `resource_id` int
column and a string 'url' column.

### Contributing

Contributions are welcome. Please include tests and ensure it passes [Travis](https://travis-ci.org/playerfm/fetchable).

It's much faster to run tests locally by running the
[testdata](https://github.com/playerfm/testdata) server locally, but it works
fine using the remote version too.
