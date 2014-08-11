ActiveRecord::Schema.define do

  create_table :base_models, :force => true do |t|
    t.string  :type
    t.string  :title
    t.string  :permalink
    t.string  :extra
    t.string  :foo
  end

  create_table :posts, :force => true do |t|
  end

  create_table :post_translations, :force => true do |t|
    t.string     :locale
    t.references :post
    t.string     :subject
    t.text       :content
    t.string     :permalink
  end

  create_table :projects, :force => true do |t|
    t.integer    :number
  end

  create_table :project_translations, :force => true do |t|
    t.string     :locale
    t.references :project
    t.string     :title
    t.string     :permalink
  end

  create_table :comments, :force => true do |t|
    t.references :project
    t.integer    :number
  end

  create_table :comment_translations, :force => true do |t|
    t.string     :locale
    t.references :comment
    t.string     :title
    t.string     :category_name
    t.string     :permalink
  end

end
