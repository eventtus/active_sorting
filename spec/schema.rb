ActiveRecord::Schema.define version: 0 do
  create_table :items, force: true do |t|
    t.integer :position
  end
  create_table :categories, force: true do |t|
    t.string :name
  end
  create_table :pages, force: true do |t|
    t.string :title
    t.integer :category_id
    t.integer :weight
  end
end
