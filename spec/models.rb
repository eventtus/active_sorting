class Item < ActiveRecord::Base
  sortable :position
end

class Category < ActiveRecord::Base
end

class Page < ActiveRecord::Base
  belongs_to :category
  sortable :weight, step: 100, scope: [:category_id]
end
