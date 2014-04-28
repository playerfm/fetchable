# Adapted from https://github.com/delynn/userstamp/blob/master/lib/userstamp/migration_helper.rb

module Fetchable
  module MigrationHelper

    COLUMNS = [

      [:url, :string],

      # call properties
      [:status_code, :integer],
      [:last_modified, :datetime],
      [:size, :integer],
      [:etag, :string],
      [:fingerprint, :string],
      [:redirect_chain, :string],
      [:permanent_redirect_url, :string],
      [:received_content_type, :string],
      [:inferred_content_type, :string],

      # tracking over time
      [:fetch_fail_count, :integer, default: 0, nil: false],
      [:fetch_tried_at, :datetime],
      [:fetch_succeeded_at, :datetime],
      [:fetch_changed_at, :datetime],
      [:next_fetch_after, :datetime, default: DateTime.new(1970,1,1), nil: false],

    ]

    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods

      def fetchable_attribs

        COLUMNS.each { |col|
          column *col
        }

      end

    end

  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, Fetchable::MigrationHelper)

module ActiveRecord
  class Migration
    
      def add_fetchable_attribs(table)

        Fetchable::MigrationHelper::COLUMNS.each { |col|
          add_column *([table].concat(col)) unless column_exists?(table, col[0])
        }

      end

  end
end
