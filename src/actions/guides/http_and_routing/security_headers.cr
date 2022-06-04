class Guides::HttpAndRouting::SecurityHeaders < GuideAction
  guide_route "/http-and-routing/security-headers"

  def self.title
    "Security Headers"
  end

  def markdown : String
    <<-MD
    ## Securing actions

    Security is a very important part to building an application, and Lucky comes with a few small tools to help you out.

    If you look in your `src/actions/browser_action.cr`, you'll see Lucky has added the `Lucky::ProtectFromForgery` module, which helps to protect you against [Cross-Site Request Forgery (CSRF)](https://www.owasp.org/index.php/Cross-Site_Request_Forgery).

    There's a few other modules you can include in your actions to help secure your app against attacks. It's up to you to decide which ones work best for your needs.

    ### `SetCSPGuard`

    This module sets the HTTP header [Content-Security-Policy](https://wiki.owasp.org/index.php/OWASP_Secure_Headers_Project#csp).
    It's job is to prevent a wide range of attacks like Cross-Site Scripting.

    Include this module in the actions you want to add this to.
    A required method `csp_guard_value` must be defined

    ```crystal
    class BrowserAction < Lucky::Action
      include Lucky::SecureHeaders::SetCSPGuard

      def csp_guard_value : String
        String.build do |io|
          io << "default-src 'self' 'unsafe-eval' 'unsafe-inline' blob: https://cdn.somecss.com"
        end
      end
    end
    ```

    ### `SetFrameGuard`

    This module sets the HTTP header [X-Frame-Options](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options).
    It's job is responsible for deciding which site can call your site from within a frame.
    For more information, read up on [Clickjacking](https://en.wikipedia.org/wiki/Clickjacking).

    ```crystal
    abstract class BrowserAction < Lucky::Action
      include Lucky::SecureHeaders::SetFrameGuard

      def frame_guard_value : String
        "deny"
      end
    end
    ```

    > The `frame_guard_value` method is required, and must be `"sameorigin"`, `"deny"`, or a valid URL for your website.
    > The explicit return type (`String` in this example) is required when you override abstract method with explicit return type.

    ### `SetSniffGuard`

    This module sets the HTTP header [X-Content-Type-Options](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options).
    It's job is responsible for disabling mime type sniffing.
    For more information, read up on [MIME type security](https://docs.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/compatibility/gg622941(v=vs.85)).

    ```crystal
    abstract class BrowserAction < Lucky::Action
      include Lucky::SecureHeaders::SetSniffGuard
    end
    ```

    ### `SetXSSGuard`

    This module sets the HTTP header [X-XSS-Protection](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-XSS-Protection).
    It's job is responsible for telling the browser to not render a page if it detects cross-site scripting.
    Lucky disables this header for Internet Explorer version < 9 for you as per recommendations. Read more on [Microsoft](https://blogs.msdn.microsoft.com/ieinternals/2011/01/31/controlling-the-xss-filter/).

    ```crystal
    abstract class BrowserAction < Lucky::Action
      include Lucky::SecureHeaders::SetXSSGuard
    end
    ```

    ## Forcing SSL and HSTS

    ['Strict-Transport-Security' header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security)
    is used for telling a browser that this site should only be accessed using HTTPS.
    Lucky comes with a `Lucky::ForceSSLHandler` handler already included, but disabled by default. To enable this, go to `config/server.cr`, and set the `settings.enabled` option to `true`.

    If you would like to enable HSTS, you can add the options to the `settings.strict_transport_security` option.

    ```crystal
    # config/server.cr

    Lucky::ForceSSLHandler.configure do |settings|
      settings.enabled = LuckyEnv.production?
      settings.strict_transport_security = {max_age: 1.year, include_subdomains: true}
    end
    ```

    ## Google FLoC

    The ['Permissions-Policy' header](https://github.com/WICG/floc) is a part of Google's Federated Learning of Cohorts (FLoC)
    which is used to track browsing history instead of using 3rd-party cookies.

    Lucky disables this feature by setting the header value to `interest-cohort=()` with the `Lucky::SecureHeaders::DisableFLoC`
    module. If you want to enable this tracking for your application, you must remove the module include from your `BrowserAction`,
    then add in the specific cohort you need.
    MD
  end
end
