ActiveRecord::Schema.define do

  create_table :base_models, :force => true do |t|
    t.string  :type,      limit: 255
    t.string  :title,     limit: 255
    t.string  :permalink, limit: 255
    t.string  :extra,     limit: 255
    t.string  :foo,       limit: 255
  end

  create_table :posts, :force => true do |t|
  end

  create_table :post_translations, :force => true do |t|
    t.string     :locale,    limit: 255
    t.references :post
    t.string     :subject,   limit: 255
    t.text       :content,   limit: 65535
    t.string     :permalink, limit: 255
  end

  create_table :projects, :force => true do |t|
    t.integer    :number,    limit: 4
  end

  create_table :project_translations, :force => true do |t|
    t.string     :locale,    limit: 255
    t.references :project
    t.string     :title,     limit: 255
    t.string     :permalink, limit: 255
  end

  create_table :comments, :force => true do |t|
    t.references :project
    t.integer    :number, limit: 4
  end

  create_table :comment_translations, :force => true do |t|
    t.string     :locale,        limit: 255
    t.references :comment
    t.string     :title,         limit: 255
    t.string     :category_name, limit: 255
    t.string     :permalink,     limit: 255
  end

end
