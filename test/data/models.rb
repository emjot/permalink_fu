
class Post < ActiveRecord::Base # translated permalink; all contributing fields are validated to be present
  translates :subject, :content, :permalink
  #default_scope :include => :translations
  has_permalink :subject, :update => true, :globalize3 => true
  validates_presence_of :subject
end

class Project < ActiveRecord::Base # permalink created via both translated and non-translated fields; not all are validated to be present
  has_many :comments
  translates :title, :permalink
  has_permalink [:number, :title], :update => true, :globalize3 => true
  validates_presence_of :title
end

class Comment < ActiveRecord::Base # permalink with scope (both translated and non-translated); permalink attributes are not validated to be present
  belongs_to :project
  translates :title, :category_name, :permalink
  has_permalink [:number, :title], :update => true, :globalize3 => true, :scope => [:project_id, :category_name]
end
