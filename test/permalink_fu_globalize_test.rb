# encoding: UTF-8

# Load test_helper
require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

class PermalinkFuGlobalizeTest < ActiveSupport::TestCase

  setup do
    reset_db!
  end

  test 'translations' do
    Globalize.with_locale(:en) do
      assert_equal true, Post.translates?
      assert_equal %w(content permalink subject), Post.translated_attribute_names.map(&:to_s).sort
      p = Post.create!(:subject => 'Post 1')
      assert_equal 1, p.translations(true).size
      assert_equal :en, p.translations[0].locale
      assert_equal [:en], p.translated_locales
    end
  end

  test 'creation of permalink on new record' do
    Globalize.with_locale(:en) do
      p = Post.create!(:subject => 'Post 1')
      assert_equal 'Post 1', p.subject
      assert_equal 'post-1', p.permalink
    end
  end

  test 'change of permalink on existing record' do
    Globalize.with_locale(:en) do
      p = Post.create!(:subject => 'Post 1')
      p.update_attributes!({:subject => "Post 1 New"})
      assert_equal 'Post 1 New', p.subject
      assert_equal 'post-1-new', p.permalink
    end
  end

  test 'creation of permalink on new translation record' do
    p = Globalize.with_locale(:en) { Post.create!(:subject => 'Post 1') }
    Globalize.with_locale(:de) do
      p.update_attributes!({:subject => "Nachricht 1"})
      assert_equal 'Nachricht 1', p.subject
      assert_equal 'nachricht-1', p.permalink
    end
  end

  test 'uniqueness of permalink' do
    Globalize.with_locale(:en) do
      p = Post.create!(:subject => 'Post')
      p2 = Post.create!(:subject => 'Post')
      assert_equal 'post', p.permalink
      assert_equal 'post-2', p2.permalink
    end
  end

  test 'uniqueness of permalink on change of exiting record' do
    Globalize.with_locale(:en) do
      p = Post.create!(:subject => 'Post')
      p2 = Post.create!(:subject => 'Post2')
      p2.subject = 'Post'
      assert_equal true, p2.changed.include?('subject')
      p2.save!
      assert_equal 'post', p.permalink
      assert_equal 'post-2', p2.permalink
    end
  end

  test 'uniqueness of permalink on change of existing record using update attributes' do
    Globalize.with_locale(:en) do
      p = Post.create!(:subject => 'Post')
      p2 = Post.create!(:subject => 'Post2')
      p2.update_attributes!(:subject => 'Post')
      assert_equal 'post', p.permalink
      assert_equal 'post-2', p2.permalink
    end
  end

  test 'uniqueness of permalink in locale scope' do
    Globalize.with_locale(:en) { p = Post.create!(:subject => 'Post') }
    Globalize.with_locale(:de) do
      p2 = Post.create!(:subject => 'Post')
      assert_equal 'post', p2.permalink
    end

    Globalize.with_locale(:en) do
      p3 = Post.create!(:subject => 'Post')
      assert_equal 'post-2', p3.permalink
    end
  end

  # permalink created via both translated and non-translated fields; not all are validated to be present

  test 'two permalink attrs one translated' do
    Globalize.with_locale(:en) do
      p = Project.create!(:title => 'My Project', :number => 42)
      assert_equal '42-my-project', p.permalink
    end
  end

  test 'only one of two permalink_attrs' do
    Globalize.with_locale(:en) do
      p = Project.create!(:title => 'My Project')
      assert_equal 'my-project', p.permalink
    end
  end

  test 'change untranslated permalink attr' do
    p = Globalize.with_locale(:en) { Project.create!(:title => 'My Project', :number => 42) }
    Globalize.with_locale(:de) do
      p.update_attributes!(:title => 'Mein Projekt')
      assert_equal '42-mein-projekt', p.permalink

      p.update_attributes!(:number => 23)
      assert_equal '23-mein-projekt', p.permalink
    end

    Globalize.with_locale(:en) { assert_equal '23-my-project', p.permalink }
  end

  test 'change both permalink attrs' do
    p = Globalize.with_locale(:en) { Project.create!(:title => 'My Project', :number => 42) }
    Globalize.with_locale(:de) { p.update_attributes!(:title => 'Mein Projekt') }
    Globalize.with_locale(:en) { p.update_attributes!(:title => 'My New Project', :number => 23) }
    Globalize.with_locale(:de) { assert_equal '23-mein-projekt', p.permalink }
    Globalize.with_locale(:en) { assert_equal '23-my-new-project', p.permalink }
  end

  test 'uniqueness locale mixed translated permalink attrs' do
    Globalize.with_locale(:en) { p = Project.create!(:title => 'My Project', :number => 42) }
    Globalize.with_locale(:de) do
      p2 = Project.create!(:title => 'My Project', :number => 42)
      assert_equal '42-my-project', p2.permalink
    end

    Globalize.with_locale(:en) do
      p3 = Project.create!(:title => 'My Project', :number => 42)
      assert_equal '42-my-project-2', p3.permalink
    end
  end

  # permalink with scope (both translated and non-translated); permalink attributes are not validated to be present

  test 'create without permalink attrs' do
    Globalize.with_locale(:en) do
      p = Comment.create!
      assert_not_nil p.permalink
      assert_not_equal '', p.permalink.strip
    end
  end

  test 'uniqueness with scopes' do
    Globalize.with_locale(:en) do
      p1 = Project.create!(:title => 'My Project')
      p2 = Project.create!(:title => 'My Second Project')
      c1 = Comment.create!(:project => p1, :number => 1, :title => 'My Comment', :category_name => 'cat')
      c2 = Comment.create!(:project => p1, :number => 1, :title => 'My Comment', :category_name => 'cat2')
      c3 = Comment.create!(:project => p2, :number => 1, :title => 'My Comment', :category_name => 'cat')
      @c4 = Comment.create!(:project => p2, :number => 1, :title => 'My Comment', :category_name => 'cat2')
      c11 = Comment.create!(:project => p1, :number => 1, :title => 'My Comment', :category_name => 'cat') # double of c1

      assert_equal '1-my-comment', c1.permalink
      assert_equal '1-my-comment', c2.permalink
      assert_equal '1-my-comment', c3.permalink
      assert_equal '1-my-comment', @c4.permalink
      assert_equal '1-my-comment-2', c11.permalink # double of c1
    end

    Globalize.with_locale(:de) do
      @c4.update_attributes!({:title => 'My Comment', :category_name => 'xxx'}) # TODO change to 'cat' - like c3, but in different locale
      assert_equal '1-my-comment', @c4.permalink
    end

    Globalize.with_locale(:en) do
      assert_not_equal 'cat', @c4.category_name
      @c4.update_attributes!({:category_name => 'cat'})
      assert_equal 'cat', @c4.category_name
      assert_equal '1-my-comment-2', @c4.permalink # updated to be like c3 (in same locale as c3)
    end
  end

  test 'uniqueness with nil scopes' do
    Globalize.with_locale(:en) do
      c1 = Comment.create!(:number => 1, :title => 'My Comment')
      c2 = Comment.create!(:number => 1, :title => 'My Comment')
      c3 = Comment.create!(:number => 1, :title => 'My Other Comment')
      assert_equal '1-my-comment', c1.permalink
      assert_equal '1-my-comment-2', c2.permalink
      assert_equal '1-my-other-comment', c3.permalink
    end
  end

  test 'change permalink attr to same as other locale after switching' do
    p = Globalize.with_locale(:en) { Post.create!(:subject => 'Post') }
    Globalize.with_locale(:de) { p.update_attributes!(:subject => 'XXX') }
    Globalize.with_locale(:en) do
      p.subject = 'XXX'
      assert_equal true, p.changed.include?('subject')
      p.save!
      assert_equal 'xxx', p.permalink
    end
  end

end
