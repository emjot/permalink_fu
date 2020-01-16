# encoding: UTF-8

# Load test_helper
require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

class PermalinkFuTest < ActiveSupport::TestCase
  @@samples = {
    'This IS a Tripped out title!!.!1  (well/ not really)' => 'this-is-a-tripped-out-title1-well-not-really',
    '////// meph1sto r0x ! \\\\\\' => 'meph1sto-r0x',
    'āčēģīķļņū' => 'acegiklnu',
    '中文測試 chinese text' => 'zhong-wen-ce-shi-chinese-text',
    'fööbär' => 'foobar'
  }

  @@extra = { 'some-)()()-ExtRa!/// .data==?>    to \/\/test' => 'some-extra-data-to-test' }

  setup do
    reset_db!
  end

  #### Permalink Methods ####
    test 'should escape strings correctly' do
      @@samples.each do |from, to|
        assert_equal to, PermalinkFu.escape(from)
      end
    end

  #### ActiveRecord ####
    test 'should set permalink on single attribute' do
      m = ClassModel.new
      m.title = 'test'
      assert m.save
      assert_equal 'test', m.permalink
    end

    test 'should set permalink on multiple attributes in subclass' do
      m = SubClassHasPermalinkModel.new
      m.title = 'foo'
      m.extra = 'bar'
      assert m.save
      assert_equal 'foo-bar', m.permalink
    end

    test 'should not inherit permalink on sub class with no permalink' do
      m = SubClassNoPermalinkModel.new
      m.title = 'foo'
      assert m.save
      assert_nil m.permalink
    end

    test 'should escape permalink correctly' do
      @@samples.each do |from, to|
        m = MockModel.new
        m.title = from
        assert m.save
        assert_equal to, m.permalink
      end
    end

    test 'should escape permalink if permalink is set directly' do
      @@samples.each do |from, to|
        m = MockModel.new
        m.title = 'whatever'; m.permalink = from
        assert m.save
        assert_equal to, m.permalink
      end
    end

    test 'should escape permalink correctly if based on multiple attributes' do
      @@samples.each do |from, to|
        @@extra.each do |from_extra, to_extra|
          m = MockModelExtra.new
          m.title = from; m.extra = from_extra
          assert m.save
          assert_equal "#{to}-#{to_extra}", m.permalink
        end
      end
    end

    test 'should create unique permalinks' do
      m = MockModel.new
      m.title = 'foo'
      assert m.save
      assert_equal 'foo', m.permalink

      m2 = MockModel.new
      m2.title = 'foo'
      assert m2.save
      assert_equal 'foo-2', m2.permalink
    end

    test 'should create unique permalink when permalink assigned directly' do
      m = MockModel.new
      m.permalink = 'foo'
      assert m.save
      assert_equal 'foo', m.permalink

      m2 = MockModel.new
      m2.permalink = 'foo'
      assert m2.save
      assert_equal 'foo-2', m2.permalink
    end

    test 'should keep permalink if uniquness is false' do
      m = CommonMockModel.new
      m.title = 'foo'
      assert m.save

      m = CommonMockModel.new
      m.permalink = 'foo'
      assert m.save
      assert_equal 'foo', m.permalink
    end

    test 'should not check itself for unique permalink if unchanged' do
      m = MockModel.new
      m.title = 'bar'
      assert m.save

      m = MockModel.new
      m.title = 'test'
      assert m.save
      m.permalink = 'bar'
      m.instance_eval do
        @changed_attributes = {}
      end
      assert m.save
      assert_equal 'bar', m.permalink
    end


    test 'should check itself for unique permalink if permalink field changed' do
      m = PermalinkChangeableMockModel.new
      m.title = 'foo'
      assert m.save

      m = PermalinkChangeableMockModel.new
      m.permalink_will_change!
      m.permalink = 'foo'
      assert m.save
      assert_equal 'foo-2', m.permalink
    end

    test 'should not check itself for unique permalink if permalink field not changed' do
      m = PermalinkChangeableMockModel.new
      m.title = 'foo'
      assert m.save
      m = PermalinkChangeableMockModel.new
      m.title = 'bar'
      assert m.save
      m.permalink = 'foo'
      assert m.save
      assert_equal 'foo', m.permalink
    end

    test 'should create unique permalink if permalink is scoped' do
      m = ScopedModel.new
      m.title = 'foo'
      m.foo   = 1
      assert m.save
      assert_equal 'foo', m.permalink

      m = ScopedModel.new
      m.title = 'foo'
      m.foo   = 1
      assert m.save
      assert_equal 'foo-2', m.permalink

      m = ScopedModel.new
      m.title = 'foo'
      m.foo = 2
      assert m.save
      assert_equal 'foo', m.permalink
    end

    test 'should work on limited permalink attributes' do
      with_mocked_limit(MockModel, 'permalink', 2) do
        m   = MockModel.new
        m.title = 'BOO'
        assert m.save
        assert_equal 'bo', m.permalink
      end
    end

    test 'should limit unique permalinks' do
      with_mocked_limit(MockModel, 'permalink', 3) do
        m   = MockModel.new
        m.title = 'foo'
        assert m.save
        assert_equal 'foo', m.permalink
        m   = MockModel.new
        m.title = 'foo'
        assert m.save
        assert_equal 'f-2', m.permalink
      end
    end

    test 'should abide by if proc condition' do
      m = IfProcConditionModel.new
      m.title = 'dont make me a permalink'
      assert m.save
      assert_nil m.permalink
    end

    test 'should abide by if method condition' do
      m = IfMethodConditionModel.new
      m.title = 'dont make me a permalink'
      assert m.valid?
      assert_nil m.permalink
    end

    test 'should abide by if string condition' do
      m = IfStringConditionModel.new
      m.title = 'dont make me a permalink'
      assert m.save
      assert_nil m.permalink
    end

    test 'should abide by unless proc condition' do
      m = UnlessProcConditionModel.new
      m.title = 'make me a permalink'
      assert m.save
      assert_not_nil m.permalink
    end

    test 'should abide by unless method condition' do
      m = UnlessMethodConditionModel.new
      m.title = 'make me a permalink'
      assert m.save
      assert_not_nil m.permalink
    end

    test 'should abide by unless string condition' do
      m = UnlessStringConditionModel.new
      m.title = 'make me a permalink'
      assert m.save
      assert_not_nil m.permalink
    end

    test 'should allow override of permalink method' do
      m = OverrideModel.new
      m[:permalink] = 'the permalink'
      assert_not_equal m.permalink, m[:permalink]
    end

    test 'should create permalink from attribute not attribute accessor' do
      m = OverrideModel.new
      m.title = 'the permalink'
      assert m.save
      assert_equal 'the-permalink', m[:permalink]
    end

    test 'should not update permalink unless field changed' do
      m = NoChangeModel.new
      m.title = 'the permalink'
      assert m.save
      assert_equal 'the-permalink', m.permalink
      m.title = 'unchanged'
      assert m.save
      assert_equal 'the-permalink', m.permalink
    end

    test 'should not update permalink without update set even if field changed' do
      m = ChangedWithoutUpdateModel.new
      m.title = 'the permalink'
      assert m.save
      m.title = 'unchanged'
      assert m.save
      assert_equal 'the-permalink', m.permalink
    end

    test 'should update permalink if changed method does not exist' do
      m = OverrideModel.new
      m.title = 'the permalink'
      assert m.save
      m.title = 'new'
      assert_equal 'the-permalink', m[:permalink]
    end

    test 'should update permalink if the existing permalink is nil' do
      m = NoChangeModel.new
      m.title = 'the permalink'
      assert m.save
      assert_equal 'the-permalink', m.permalink

      m.permalink = nil
      assert m.save
      assert_equal 'the-permalink', m.permalink
    end

    test 'should update permalink if the existing permalink is blank' do
      m = NoChangeModel.new
      m.title = 'the permalink'
      assert m.save
      assert_equal 'the-permalink', m.permalink

      m.permalink = ''
      assert m.save
      assert_equal 'the-permalink', m.permalink
    end

    test 'should assign a random permalink if the title is nil' do
      m = NoChangeModel.new
      m.title = nil
      assert m.save
      assert_not_nil m.permalink
      assert m.permalink.size > 0
    end

    test 'should assign a random permalink if the title has no permalinkable characters' do
      m = NoChangeModel.new
      m.title = '////'
      assert m.save
      assert_not_nil m.permalink
      assert m.permalink.size > 0
    end

    test 'should update permalink the first time the title is set' do
      m = ChangedWithoutUpdateModel.new
      m.title = 'old title'
      assert m.save
      assert_equal 'old-title', m.permalink
      m.title = 'new title'
      assert m.save
      assert_equal 'old-title', m.permalink
    end

    test 'should not update permalink if already set even if title changed' do
      m = ChangedWithoutUpdateModel.new
      m.title = 'new title'
      m.permalink = 'old permalink'
      assert m.save
      assert_equal 'old-permalink', m.permalink
    end

    test 'should_update_permalink_every_time_the_title_is_changed' do
      m = ChangedWithUpdateModel.new
      m.title = 'old title'
      assert m.save
      assert_equal 'old-title', m.permalink
      m.title = 'new title'
      assert m.save
      assert_equal 'new-title', m.permalink
    end

    test 'should work correctly for scoped fields with nil value' do
      s1 = ScopedModelForNilScope.new
      s1.title = 'ack'
      s1.foo = 3
      assert s1.save
      assert_equal 'ack', s1.permalink

      s2 = ScopedModelForNilScope.new
      s2.title = 'ack'
      s2.foo = nil
      assert s2.valid?
      assert_equal 'ack', s2.permalink
    end
end
