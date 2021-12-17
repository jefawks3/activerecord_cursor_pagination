# frozen_string_literal: true

class Schema < ActiveRecord::Migration[5.2]
  create_table "posts", force: :cascade do |t|
    t.text :body
    t.boolean :published, default: false
    t.timestamps
  end
end
