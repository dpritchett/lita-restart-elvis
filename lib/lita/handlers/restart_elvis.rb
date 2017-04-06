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
        result = heroku.dyno.restart_all(dyno_name)
      end

      def dyno_info(app_name)
        infos = heroku.dyno.list(app_name)

        infos.map { |i| "#{i.fetch('name')}\t#{i.fetch('state')}\tboot time: #{i.fetch('created_at')}" }.join("\n")
      end

      def restart_bot(response)
        app_name = ENV.fetch('HEROKU_RESTARTABLE_APP_NAME')

        response.reply 'Please hold...'

        restart_dyno_named app_name

        sleep 5
        msg = dyno_info(app_name)

        response.reply "Done.  Status: #{msg}"
      end

      Lita.register_handler(self)
    end
  end
end
