
class Post < ActiveRecord::Base # translated permalink; all contributing fields are validated to be present
  translates :subject, :content, :permalink
  #default_scope :include => :translations
  has_permalink :subject, :update => true, :globalize => true
  validates_presence_of :subject
end

class Project < ActiveRecord::Base # permalink created via both translated and non-translated fields; not all are validated to be present
  has_many :comments
  translates :title, :permalink
  has_permalink [:number, :title], :update => true, :globalize => true
  validates_presence_of :title
end

class Comment < ActiveRecord::Base # permalink with scope (both translated and non-translated); permalink attributes are not validated to be present
  belongs_to :project
  translates :title, :category_name, :permalink
  has_permalink [:number, :title], :update => true, :globalize => true, :scope => [:project_id, :category_name]
end

class BaseModel < ActiveRecord::Base
end

class ClassModel < BaseModel
  has_permalink :title
end

class SubClassHasPermalinkModel < ClassModel
  has_permalink [:title, :extra]
end

class SubClassNoPermalinkModel < ClassModel
end

class MockModel < BaseModel
  has_permalink :title
end

class MockModelExtra < BaseModel
  has_permalink [:title, :extra]
end

class PermalinkChangeableMockModel < BaseModel
  has_permalink :title

  def permalink_changed?
    @permalink_changed
  end

  def permalink_will_change!
    @permalink_changed = true
  end
end

class CommonMockModel < BaseModel
  has_permalink :title, :unique => false
end

class ScopedModel < BaseModel
  has_permalink :title, :scope => :foo
end

class ScopedModelForNilScope < BaseModel
  has_permalink :title, :scope => :foo
end

class OverrideModel < BaseModel
  has_permalink :title

  def permalink
    'not the permalink'
  end
end

class ChangedWithoutUpdateModel < BaseModel
  has_permalink :title
  def title_changed?; true; end
end

class ChangedWithUpdateModel < BaseModel
  has_permalink :title, :update => true
  def title_changed?; true; end
end

class NoChangeModel < BaseModel
  has_permalink :title, :update => true
  def title_changed?; false; end
end

class IfProcConditionModel < BaseModel
  has_permalink :title, :if => Proc.new { |obj| false }
end

class IfMethodConditionModel < BaseModel
  has_permalink :title, :if => :false_method

  def false_method; false; end
end

class IfStringConditionModel < BaseModel
  has_permalink :title, :if => 'false'
end

class UnlessProcConditionModel < BaseModel
  has_permalink :title, :unless => Proc.new { |obj| false }
end

class UnlessMethodConditionModel < BaseModel
  has_permalink :title, :unless => :false_method

  def false_method; false; end
end

class UnlessStringConditionModel < BaseModel
  has_permalink :title, :unless => 'false'
end

