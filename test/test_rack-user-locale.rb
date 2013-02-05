require 'helper'

describe "RackUserLocale" do
  describe "without accepted_locales set" do
    before do
      def app
        app = Rack::Builder.new {
          use Rack::UserLocale

          run BasicRackApp.new
        }
      end

      I18n.default_locale = :en
    end

    it "should have I18n.locale set to :en initially" do
      assert_equal :en, I18n.locale
    end

    describe "when a locale cookie is set" do
      before do
        get 'http://example.com/', {}, 'HTTP_COOKIE' => 'user-locale=be'
      end

      it "should have I18n.locale set to :be" do
        assert_equal :be, I18n.locale
      end

      it "should not set a cookie in the response" do
        assert_equal nil, last_response["Set-Cookie"]
      end
    end

    describe "when from HTTP_ACCEPT_LANGUAGE headers" do
      before do
        get 'http://example.com/', {}, 'HTTP_ACCEPT_LANGUAGE' => 'fr-be'
      end

      it "should have I18n.locale set to :fr" do
        assert_equal :fr, I18n.locale
      end

      it "should set a cookie in the response" do
        assert_equal "user-locale=fr; domain=example.com; path=/", last_response["Set-Cookie"]
      end
    end

    describe "when both a cooke and HTTP_ACCEPT_LANGUAGE headers are set" do
      before do
        get 'http://example.com/', {}, 'HTTP_COOKIE' => 'user-locale=af', 'HTTP_ACCEPT_LANGUAGE' => 'ar-sa'
      end

      it "should have I18n.locale set to :af" do
        assert_equal :af, I18n.locale
      end

      it "should not set a cookie in the response" do
        assert_equal nil, last_response["Set-Cookie"]
      end
    end

    describe "when nothing is changed" do
      before do
        get 'http://example.com/'
      end

      it "should have I18n.locale set to :en" do
        assert_equal :en, I18n.locale
      end

      it "should set a cookie in the response" do
        assert_equal "user-locale=en; domain=example.com; path=/", last_response["Set-Cookie"]
      end
    end
  end

  describe "with accepted_locales set" do
    before do
      def app
        app = Rack::Builder.new {
          use Rack::UserLocale, :accepted_locales => [:en, :es, :fr, :de, :jp]

          run BasicRackApp.new
        }
      end

      I18n.default_locale = :en
    end

    it "should have I18n.locale set to :en initially" do
      assert_equal :en, I18n.locale
    end

    describe "when a locale cookie is set" do
      before do
        get 'http://example.com/', {}, 'HTTP_COOKIE' => 'user-locale=es'
      end

      it "should have I18n.locale set to :es" do
        assert_equal :es, I18n.locale
      end

      it "should not set a cookie in the response" do
        assert_equal nil, last_response["Set-Cookie"]
      end
    end

    describe "when from HTTP_ACCEPT_LANGUAGE headers" do
      describe "with an accepted locale" do
        before do
          get 'http://example.com/', {}, 'HTTP_ACCEPT_LANGUAGE' => 'fr-be'
        end

        it "should have I18n.locale set to :fr" do
          assert_equal :fr, I18n.locale
        end

        it "should set a cookie in the response" do
          assert_equal "user-locale=fr; domain=example.com; path=/", last_response["Set-Cookie"]
        end
      end

      describe "without an accepted locale" do
        before do
          get 'http://example.com/', {}, 'HTTP_ACCEPT_LANGUAGE' => 'ar-sa'
        end

        it "should have I18n.locale set to :en" do
          assert_equal :en, I18n.locale
        end

        it "should set a cookie in the response" do
          assert_equal "user-locale=en; domain=example.com; path=/", last_response["Set-Cookie"]
        end
      end
    end

    describe "when both a cooke and HTTP_ACCEPT_LANGUAGE headers are set" do
      before do
        get 'http://example.com/', {}, 'HTTP_COOKIE' => 'user-locale=jp', 'HTTP_ACCEPT_LANGUAGE' => 'fr-be'
      end

      it "should have I18n.locale set to :jp" do
        assert_equal :jp, I18n.locale
      end

      it "should not set a cookie in the response" do
        assert_equal nil, last_response["Set-Cookie"]
      end
    end

    describe "when nothing is changed" do
      before do
        get 'http://example.com/'
      end

      it "should have I18n.locale set to :en" do
        assert_equal :en, I18n.locale
      end

      it "should set a cookie in the response" do
        assert_equal "user-locale=en; domain=example.com; path=/", last_response["Set-Cookie"]
      end
    end
  end
end
