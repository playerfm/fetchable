module Fetchable

  class Fetcher

    # http://shadow-file.blogspot.co.uk/2009/03/handling-http-redirection-in-ruby.html
    def self.deep_fetch(fetchable, url, redirect_chain, options)

      headers = Hashie::Mash.new
      headers['if-none-match'] = fetchable.etag if fetchable.etag.present?
      headers['if-modified-since'] = fetchable.last_modified.rfc2822 if fetchable.last_modified.present?

      options = Hashie::Mash.new(read_timeout: 60, connect_timeout: 10).merge(options)

      resp = Excon.get url, {
        headers: headers,
        omit_default_port: true,
        read_timeout: options.read_timeout,
        connect_timeout: options.connect_timeout
      }

      if [301,302,303].include?(resp.status) and redirect_chain.size <= options.redirect_limit
        new_url = resp.headers['location']
        if URI.parse(new_url).relative?
          old_url = Addressable::URI.parse(url)
          port = '' if [old_url.port, old_url.scheme] == [80, 'http'] || [old_url.port, old_url.scheme] == [443, 'https']
          new_url = "#{old_url.scheme}://#{old_url.host}:#{port}#{resp.headers['location']}"
        end
        # Use URI.parse() instead of raw URL because raw URL string includes
        # unnecessary :80 and :443 port number
        redirect_chain << { url: URI.parse(new_url).to_s, status_code: resp.status }
        return self.deep_fetch(fetchable, new_url, redirect_chain, options)
      end

      [resp, options, redirect_chain]

    end

  end

end
