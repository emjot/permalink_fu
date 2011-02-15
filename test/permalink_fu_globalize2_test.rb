# encoding: UTF-8

# Load the plugin's test_helper (Rails 2.x needs the path)
begin
  require File.dirname(__FILE__) + '/test_helper.rb'
  require File.dirname(__FILE__) + '/test_helper_globalize2.rb'
  require File.expand_path(File.dirname(__FILE__) + '/data/models')
rescue LoadError
  require 'test_helper'
  require 'test_helper_globalize2'
  require 'data/models'
end


class PermalinkFuGlobalize2Test < ActiveSupport::TestCase

  def setup
    I18n.locale = :en
    reset_db!
    ActiveRecord::Base.locale = nil
  end

  def test_translations
    assert_equal true, Post.translates?
    assert_equal %w(content permalink subject), Post.translated_attribute_names.map(&:to_s).sort
    p = Post.create!(:subject => 'Post 1')
    assert_equal 1, p.translations(true).size
    assert_equal :en, p.translations[0].locale
    assert_equal [:en], p.translated_locales
  end

  def test_create_on_new
    p = Post.create!(:subject => 'Post 1')
    assert_equal 'Post 1', p.subject
    assert_equal 'post-1', p.permalink
  end

  def test_change_on_existing
    p = Post.create!(:subject => 'Post 1')
    p.update_attributes!({:subject => "Post 1 New"})
    assert_equal 'Post 1 New', p.subject
    assert_equal 'post-1-new', p.permalink
  end

  def test_create_on_new_translation
    p = Post.create!(:subject => 'Post 1')
    I18n.locale = :de
    p.update_attributes!({:subject => "Nachricht 1"})
    assert_equal 'Nachricht 1', p.subject
    assert_equal 'nachricht-1', p.permalink
    I18n.locale = :en
  end

  def test_uniqueness
    p = Post.create!(:subject => 'Post')
    p2 = Post.create!(:subject => 'Post')
    assert_equal 'post', p.permalink
    assert_equal 'post-2', p2.permalink
  end

  def test_uniqueness_on_change
    p = Post.create!(:subject => 'Post')
    p2 = Post.create!(:subject => 'Post2')
    p2.subject = 'Post'
    assert_equal true, p2.subject_changed?
    p2.save!
    assert_equal 'post', p.permalink
    assert_equal 'post-2', p2.permalink
  end

  def test_uniqueness_on_change_using_update_attributes
    p = Post.create!(:subject => 'Post')
    p2 = Post.create!(:subject => 'Post2')
    p2.update_attributes!(:subject => 'Post')
    assert_equal 'post', p.permalink
    assert_equal 'post-2', p2.permalink
  end

  def test_uniqueness_locale_scope
    p = Post.create!(:subject => 'Post')
    I18n.locale = :de
    p2 = Post.create!(:subject => 'Post')
    assert_equal 'post', p2.permalink
    I18n.locale = :en
    p3 = Post.create!(:subject => 'Post')
    assert_equal 'post-2', p3.permalink
  end

  # permalink created via both translated and non-translated fields; not all are validated to be present

  def test_two_permalink_attrs_one_translated
    p = Project.create!(:title => 'My Project', :number => 42)
    assert_equal '42-my-project', p.permalink 
  end

  def test_only_one_of_two_permalink_attrs
    p = Project.create!(:title => 'My Project')
    assert_equal 'my-project', p.permalink
  end

  def test_change_untranslated_permalink_attr
    p = Project.create!(:title => 'My Project', :number => 42)
    I18n.locale = :de
    p.update_attributes!(:title => 'Mein Projekt')
    assert_equal '42-mein-projekt', p.permalink

    p.update_attributes!(:number => 23)
    assert_equal '23-mein-projekt', p.permalink
    I18n.locale = :en
    assert_equal '23-my-project', p.permalink
  end

  def test_change_both_permalink_attrs
    p = Project.create!(:title => 'My Project', :number => 42)
    I18n.locale = :de
    p.update_attributes!(:title => 'Mein Projekt')
    I18n.locale = :en
    p.update_attributes!(:title => 'My New Project', :number => 23)
    I18n.locale = :de
    assert_equal '23-mein-projekt', p.permalink
    I18n.locale = :en
    assert_equal '23-my-new-project', p.permalink
  end

  def test_uniqueness_locale_mixed_translated_permalink_attrs
    p = Project.create!(:title => 'My Project', :number => 42)
    I18n.locale = :de
    p2 = Project.create!(:title => 'My Project', :number => 42)
    assert_equal '42-my-project', p2.permalink
    I18n.locale = :en
    p3 = Project.create!(:title => 'My Project', :number => 42)
    assert_equal '42-my-project-2', p3.permalink
  end

  # permalink with scope (both translated and non-translated); permalink attributes are not validated to be present

  def test_create_without_permalink_attrs
    p = Comment.create!
    assert_not_nil p.permalink
    assert_not_equal '', p.permalink.strip
  end

  def test_uniqueness_with_scopes
    p1 = Project.create!(:title => 'My Project')
    p2 = Project.create!(:title => 'My Second Project')
    c1 = Comment.create!(:project => p1, :number => 1, :title => 'My Comment', :category_name => 'cat')
    c2 = Comment.create!(:project => p1, :number => 1, :title => 'My Comment', :category_name => 'cat2')
    c3 = Comment.create!(:project => p2, :number => 1, :title => 'My Comment', :category_name => 'cat')
    c4 = Comment.create!(:project => p2, :number => 1, :title => 'My Comment', :category_name => 'cat2')
    c11 = Comment.create!(:project => p1, :number => 1, :title => 'My Comment', :category_name => 'cat') # double of c1

    assert_equal '1-my-comment', c1.permalink
    assert_equal '1-my-comment', c2.permalink
    assert_equal '1-my-comment', c3.permalink
    assert_equal '1-my-comment', c4.permalink
    assert_equal '1-my-comment-2', c11.permalink # double of c1

    I18n.locale = :de
    c4.update_attributes!({:title => 'My Comment', :category_name => 'xxx'}) # TODO change to 'cat' - like c3, but in different locale
    assert_equal '1-my-comment', c4.permalink

    I18n.locale = :en
    assert_not_equal 'cat', c4.category_name
    c4.update_attributes!({:category_name => 'cat'})
    assert_equal 'cat', c4.category_name
    assert_equal '1-my-comment-2', c4.permalink # updated to be like c3 (in same locale as c3)
  end

  def test_uniqueness_with_nil_scopes
    c1 = Comment.create!(:number => 1, :title => 'My Comment')
    c2 = Comment.create!(:number => 1, :title => 'My Comment')
    c3 = Comment.create!(:number => 1, :title => 'My Other Comment')
    assert_equal '1-my-comment', c1.permalink
    assert_equal '1-my-comment-2', c2.permalink
    assert_equal '1-my-other-comment', c3.permalink
  end

  # NOTE that this test is currently failing
  def test_change_permalink_attr_to_same_as_other_locale_after_switching
    p = Post.create!(:subject => 'Post')
    I18n.locale = :de
    p.update_attributes!(:subject => 'XXX')
    I18n.locale = :en
    p.update_attributes(:subject => 'XXX')
    assert_equal true, p.subject_changed? # FIXME - this is the problem why permalink will also fail in this situation
    p.save!
    assert_equal 'xxx', p.permalink
  end

end
