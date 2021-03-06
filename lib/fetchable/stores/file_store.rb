module Fetchable

  module Stores

    class FileStore

      # these take priority before delegating to MIME::Types
      PREFERRED_EXTENSIONS = {
        'image/jpeg' => 'jpeg',
        'text/plain' => 'txt'
      }

      attr_accessor :folder, :name_prefix 

      def initialize(settings={})
        settings = Hashie::Mash.new(settings)
        @folder = settings.folder # we have to defer the default as Rails.root doesn't exist yet
        @name_prefix = settings.name_prefix || "res"
        @subfolder_amount = settings.subfolder_amount || 1000
      end

      def get_folder
        @folder || "#{Rails.root}/public/fetchables"
      end

      def key_of(fetchable)
        folder = "#{get_folder}"
        folder += "/#{fetchable.id % @subfolder_amount}" if @subfolder_amount > 0
        FileUtils.mkdir_p(folder) unless File.directory?(folder)
        filename = "#{@name_prefix}#{Fetchable::Util.encode(fetchable.id)}#{self.class.determine_extension fetchable}"
        "#{folder}/#{filename}"
      end

      def save_content(fetchable, response, now, options)
        if fetchable.fetch_changed_at==now
          File.open(self.key_of(fetchable), 'wb') {|f| f.write(response.body) }
        end
      end

      def self.determine_extension(fetchable)
        if preferred_extension = PREFERRED_EXTENSIONS[fetchable.received_content_type] || PREFERRED_EXTENSIONS[fetchable.inferred_content_type]
          ".#{preferred_extension}"
        else
          types = MIME::Types[fetchable.received_content_type]
          types = MIME::Types[fetchable.inferred_content_type] if types.blank?
          if types and types.first and extension = types.first.extensions[0]
            ".#{extension}"
          else
            ''
          end
        end
      end

    end

  end

end
