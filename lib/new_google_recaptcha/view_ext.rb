module NewGoogleRecaptcha
  module ViewExt
    include ActionView::Helpers::TagHelper

    def include_recaptcha_js(opts = {})
      badge = opts[:badge] ? "&badge=#{opts[:badge]}" : ""
      generate_recaptcha_callback +
        javascript_include_tag(
          "https://www.google.com/recaptcha/api.js?render=#{NewGoogleRecaptcha.site_key}&onload=newGoogleRecaptchaCallback#{badge}",
          defer: true
        )
    end

    def recaptcha_action(action)
      id = "new_google_recaptcha_token_#{SecureRandom.hex(10)}"
      raw %Q{
        <input
          name="new_google_recaptcha_token"
          type="hidden" id="#{id}"
          readonly="true"
          data-google-recaptcha-action="#{action}"
        />
        <script>
          if (grecaptcha) {
            grecaptcha.ready(function() {
              grecaptcha
                .execute("#{NewGoogleRecaptcha.site_key}", {action: "#{action}"})
                .then(function(token) {
                  document.getElementById("#{id}").value = token
                })
            })
          }
        </script>
      }
    end

    private

    def generate_recaptcha_callback
      javascript_tag %(
        function newGoogleRecaptchaCallback() {
          grecaptcha.ready(function() {
            function getReCaptcha() {
              var elements = document.querySelectorAll('[data-google-recaptcha-action]')
              Array.prototype.slice.call(elements).forEach(function (el) {
                var action = el.dataset.googleRecaptchaAction
                if (!action) return
                grecaptcha
                  .execute("#{NewGoogleRecaptcha.site_key}", { action: action })
                  .then(function (token) {
                    el.value = token
                  })
              })
            }
            getReCaptcha()
            setInterval(function() {
              getReCaptcha()
            }, 100000)
          })
        }
      )
    end
  end
end
