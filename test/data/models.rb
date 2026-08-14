# frozen_string_literal: true

# translated permalink; all contributing fields are validated to be present
class Post < ActiveRecord::Base
  translates :subject, :content, :permalink
  # default_scope :include => :translations
  has_permalink :subject, update: true, globalize: true
  validates_presence_of :subject
end

# permalink created via both translated and non-translated fields; not all are validated to be present
class Project < ActiveRecord::Base
  has_many :comments
  translates :title, :permalink
  has_permalink %i[number title], update: true, globalize: true
  validates_presence_of :title
end

# permalink with scope (both translated and non-translated); permalink attributes are not validated to be present
class Comment < ActiveRecord::Base
  belongs_to :project
  translates :title, :category_name, :permalink
  has_permalink %i[number title], update: true, globalize: true, scope: %i[project_id category_name]
end

class BaseModel < ActiveRecord::Base
end

class ClassModel < BaseModel
  has_permalink :title
end

class SubClassHasPermalinkModel < ClassModel
  has_permalink %i[title extra]
end

class SubClassNoPermalinkModel < ClassModel
end

class MockModel < BaseModel
  has_permalink :title
end

class MockModelShortPermalink < BaseModel
  has_permalink [:title], :short_permalink
end

class MockModelExtra < BaseModel
  has_permalink %i[title extra]
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
  has_permalink :title, unique: false
end

class ScopedModel < BaseModel
  has_permalink :title, scope: :foo
end

class ScopedModelForNilScope < BaseModel
  has_permalink :title, scope: :foo
end

class OverrideModel < BaseModel
  has_permalink :title

  def permalink
    'not the permalink'
  end
end

class ChangedWithoutUpdateModel < BaseModel
  has_permalink :title
  def title_changed? = true
end

class ChangedWithUpdateModel < BaseModel
  has_permalink :title, update: true
  def title_changed? = true
end

class NoChangeModel < BaseModel
  has_permalink :title, update: true
  def title_changed? = false
end

class IfProcConditionModel < BaseModel
  has_permalink :title, if: proc { |_obj| false }
end

class IfMethodConditionModel < BaseModel
  has_permalink :title, if: :false_method

  def false_method = false
end

class IfStringConditionModel < BaseModel
  has_permalink :title, if: 'false'
end

class UnlessProcConditionModel < BaseModel
  has_permalink :title, unless: proc { |_obj| false }
end

class UnlessMethodConditionModel < BaseModel
  has_permalink :title, unless: :false_method

  def false_method = false
end

class UnlessStringConditionModel < BaseModel
  has_permalink :title, unless: 'false'
end
