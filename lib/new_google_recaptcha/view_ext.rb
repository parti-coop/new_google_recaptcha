module NewGoogleRecaptcha
  module ViewExt
    include ActionView::Helpers::TagHelper

    def include_recaptcha_js
      raw %Q{
        <script src="https://www.google.com/recaptcha/api.js?render=#{NewGoogleRecaptcha.site_key}"></script>
      }
    end

    def recaptcha_action(action, **options)
      id = "new_google_recaptcha_token_#{SecureRandom.hex(10)}"
      raw %Q{
        <input name="new_google_recaptcha_token" type="hidden" id="#{id}" #{
          options.map do |key, value|
            "#{key}=\"#{h(value)}\""
          end.join(' ')
        }/>
        <script>
          async function executeRecaptchaFor#{sanitize_action_for_js(action)}Async() {
            return new Promise(function(resolve, reject) {
              grecaptcha.ready(async function() {
                resolve(await grecaptcha.execute('#{NewGoogleRecaptcha.site_key}', {action: '#{action}'}));
              });
            });
          }
        </script>
      }
    end

    private

    def sanitize_action_for_js(action)
      action.to_s.gsub(/\W/, '_').split(/\/|_/).map(&:capitalize).join
    end
  end
end
