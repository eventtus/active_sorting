require 'active_sorting/model'

module ActiveSorting
  class Engine < Rails::Engine # :nodoc:
    ActiveSupport.on_load(:active_record) do
      ActiveRecord::Base.send(:include, ActiveSorting::Model)
    end
  end
end
