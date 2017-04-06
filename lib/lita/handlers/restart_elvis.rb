require 'platform-api'

module Lita
  module Handlers
    class RestartElvis < Handler
      route /^restart elvis$/i,
            :restart_bot,
            command: true,
            help: { 'restart elvis' => 'asks the heroku API to bounce elvis' }

      BLOG_URL = 'https://whatsbradeating.tumblr.com'.freeze

      def heroku
        @_heroku ||= PlatformAPI.connect_oauth(ENV.fetch('HEROKU_OAUTH_TOKEN'))
      end

      def restart_dyno_named(dyno_name)
        heroku.dyno.restart_all(dyno_name)
      end

      def restart_bot(response)
        restart_dyno_named ENV.fetch('HEROKU_RESTARTABLE_APP_NAME')

        response.reply 'I may have restarted, IDK'
      end

      Lita.register_handler(self)
    end
  end
end
