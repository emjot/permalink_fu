# PermalinkFu

[![Build Status](https://travis-ci.org/emjot/permalink_fu.svg?branch=globalize)](https://travis-ci.org/emjot/permalink_fu)

This is a fork of goncalossilva/permalink_fu, a simple plugin for creating URL-friendly permalinks (slugs) from attributes.

It supports globalize model translations in the following branches:

* globalize branch: [globalize](https://github.com/globalize/globalize) 5.x / Rails 4.2-5.x (contains up-to-date usage instructions)
* globalize4 branch: [globalize4](https://github.com/globalize/globalize4) 4.x / Rails 4 (old, contains usage instructions)
* globalize3 branch: [globalize3](https://github.com/svenfuchs/globalize3) 0.3.x / Rails 3 (old, without usage instructions)
* globalize2 branch: [globalize2](https://github.com/joshmh/globalize2) for Rails 2 (old, without usage instructions)

## Usage

    class Article < ActiveRecord::Base
      has_permalink :title
    end

This will escape the title in a before_validation callback, turning e.g. "Föö!! Bàr" into "foo-bar".

The permalink is by default stored in the `permalink` attribute.

    has_permalink :title, :as => :slug
  
will store it in `slug` instead.

    has_permalink [:category, :title]
  
will store a permalink form of `"#{category}-#{title}"`.

Permalinks are guaranteed unique: "foo-bar-2", "foo-bar-3" etc are used if there are conflicts. You can set the scope of the uniqueness like

    has_permalink :title, :scope => :blog_id

This means that two articles with the same `blog_id` can not have the same permalink, but two articles with different `blog_id`s can.

Two finders are provided:

    Article.find_by_permalink(params[:id])
    Article.find_by_permalink!(params[:id])
    
These methods keep their name no matter what attribute is used to store the permalink.

The `find_by_permalink` method returns `nil` if there is no match; the `find_by_permalink!` method will raise `ActiveRecord::RecordNotFound`.

You can override the model's `to_param` method with

    has_permalink :title, :param => true
    
This means that the permalink will be used instead of the primary key (id) in generated URLs. Remember to change your controller code from e.g. `find` to `find_by_permalink!`.

You can add conditions to `has_permalink` like so:

  	class Article < ActiveRecord::Base
  	  has_permalink :title, :if => Proc.new { |article| article.needs_permalink? }
  	end

Use the `:if` or `:unless` options to specify a Proc, method, or string to be called or evaluated. The permalink will only be generated if the option evaluates to true.

You can use `PermalinkFu.escape` to escape a string manually.

## Use with Globalize gem

    class Article < ActiveRecord::Base   
      translates :title, :permalink
      
      has_permalink :title, :globalize => true
    end

Just add the `:globalize => true` option when the permalink is based on translated attributes. You will also need
to translate the permalink field itself.  

Note:

* mixing translated and untranslated attributes for `has_permalink` is currently not supported
* when using the `globalize` option, it automatically adds a `:locale` scope when determining the permalink uniqueness  

## Development and Testing

If you change any gem dependencies, you need to re-generate the gemfiles via `bundle exec appraisal update`.
  
To setup tests, make sure all the ruby versions defined in `.travis.yml` are installed on your system.

Run tests via:

* `rake wwtd` (or, faster: `rake wwtd:parallel`) for all combinations of ruby/rails versions
* `rake wwtd:local` for all rails versions, but only on current ruby
* `rake spec` (or e.g. `bundle exec rspec spec --format documentation`) with main Gemfile and only on current ruby 


## Credits

Originally extracted from [Mephisto](http://mephistoblog.com) by [technoweenie](http://github.com/technoweenie/permalink_fu/).

Conditions added by [Pat Nakajima](http://github.com/nakajima/permalink_fu/).

[Henrik Nyh](http://github.com/technoweenie/permalink_fu/) replaced `iconv` with `ActiveSupport::Multibyte`.
