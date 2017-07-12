require 'sinatra'
require 'line/bot'
require 'json'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = 'YOUR_CHANNEL_SECRET'
    config.channel_token = 'YOUR_CHANNEL_ACCESS_TOKEN'
  }
end

post '/' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    if event['type'] == 'message' then
      if event['message']['type'] == 'text' then
        if event['message']['text'] == 'こんにちは' then
          profile = client.get_profile(event['source']['userId']);
          displayName = JSON.parse(profile.body)['displayName']

          message = [
            {
              type: 'sticker',
              packageId: 1,
              stickerId: 17
            },
            {
              type: 'text',
              text: 'こんにちは！' + displayName + 'さん'
            }
          ]
          client.reply_message(event['replyToken'], message)
        else
          message = [
            {
              type: 'text',
              text: '「こんにちは」と呼びかけて下さいね！'
            },
            {
              type: 'sticker',
              packageId: 1,
              stickerId: 4
            }
          ]
          client.reply_message(event['replyToken'], message)
        end
      end
    end
  }

end
