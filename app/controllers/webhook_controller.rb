require 'line/bot'
require 'json'

class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    #render :json => build_template("35.6062227", "139.7327419")
    file = File.read("db/Quest.json")
    data =  JSON.parse(file)
    event =
    { 
      "message" => {"text" => "お昼" },    
      "type"=>"postback", "replyToken"=>"3f6181ec73fd4b46bc4d11c104295fb9", 
      "source"=>{"userId"=>"Ubcd2b753b73e467880b4ab3f47f35d13", "type"=>"user"}, 
      "timestamp"=>1503330495189, 
      "postback"=>{"data"=>"id=8&parent_id=1"}
    }      
   # execute_post_back(evnet,data)
    render plain: execute(event,data)
  end

  def callback
    file = File.read("db/Quest.json")
    data =  JSON.parse(file)

    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
       render status: 400, json: { message: 'OK' }
    end  

    events = client.parse_events_from(body)
    events.each { |event|
      case event
        when Line::Bot::Event::Message
          case event.type
            when Line::Bot::Event::Follow
              client.push_message(event['source']['userId'], "友達登録ありがとうございます！")
            when Line::Bot::Event::MessageType::Text
              message = execute(event,data)    
              client.reply_message(event['replyToken'], message)
            when Line::Bot::Event::MessageType::Location
              message = execute_near_rest(event)
              client.reply_message(event['replyToken'], message)
          end
        when Line::Bot::Event::Postback
          message = execute_post_back(event,data)    
          client.reply_message(event['replyToken'], message)
      end  
  } 
  render plain: "ok"
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end 

  def execute(event, data)
    text = event.message['text']
    if text.include?("お昼")
      @altText = data[0]["label"]
      @type = template_type.find {|item| item == "confirm" }
      @confirm_actions = []
        data[0]["children"].each do |a|
          @label = a["label"]
          @text = a["label"]  
          @post_id = "id="+ a["id"].to_s+ "&"+ "parent_id="+ a["parent_id"].to_s
          @confirm_actions.push(confirm_actions[0])
        end
      reply_template
    elsif text.split(',').size == 2
      gurunabi=  Gurunabi.new 
      rests = gurunabi.default_search(text.split(',')[0])
      data = Food.budget_search(rests["rest"],text.split(',')[1])
      result = "検索の結果は\n\n"
      data.each do | item | 
        result = result << item["name"] << "\n"
        result = result << item["url_mobile"] << "\n"
        result = result << item["opentime"] << "\n"
        result = result << "ランチ:" << item["lunch"] << "\n"
        result = result << "\n\n"
      end
      reply_text(result)  
    else
      reply_text("こんにちは、お昼を探したいとき、場所と予算の間に区切り文字','を入れれば検索できる,例えば　新橋,600")
    end
  end

  def execute_post_back(event,data)
    id = event["postback"]["data"].split("&")[0].split("=")[1].to_i
    parent_id = event["postback"]["data"].split("&")[1].split("=")[1].to_s
    data.extend(Hashie::Extensions::DeepLocate)
    data = data.deep_locate -> (key, value, object) { key == "id" && value == id }
    data.extend(Hashie::Extensions::DeepLocate)
    data = data.deep_locate -> (key, value, object) { key == "parent_id" && value == parent_id }
    result = data
    binding.pry
    if result[0].key?("children")  
      @confirm_actions = []
      @altText = result[0]["label"]
      @type = template_type.find {|item| item == "buttons" }
      if result[0]["children"].size > 1
        result[0]["children"].each do |a|
          @label = a["label"]
          @text = a["label"]
          @post_id = "id="+ a["id"].to_s+ "&"+ "parent_id="+ a["parent_id"].to_s
          @confirm_actions.push(confirm_actions[0])
        end
        TalkDatum.create(user_id: event['source']['userId'], type: event['source']['type'], content: "", current_qid: id, next_qid: parent_id)
        reply_template
      else
        if result[0]["next_type"] == "search" 
          # keywordを入れてdbに保存
          TalkDatum.create(user_id: event['source']['userId'], type: event['source']['type'], content: "", current_qid: id, next_qid: parent_id)
          reply_text(result[0]["to_web"])  
        end
      end
    else
      TalkDatum.create(user_id: event['source']['userId'], type: event['source']['type'], content: "", current_qid: id, next_qid: parent_id)
      reply_text(result[0]["to_web"])  
    end 
  end
  
  def execute_near_rest(event)
    build_template(event['message']['latitude'].to_s,event['message']['longitude'].to_s)
  end

  def build_template(latitude, longitude)
    gurunabi=  Gurunabi.new
    rests = gurunabi.search_by_latitude_longitude(latitude,longitude)
    data = Food.rests_list(rests["rest"],latitude,longitude)
    @columns = []
    data.each do | item | 
      @title = item["name"]
      @distance = item["distance"]
      @address = item["address"]
      @googleSearchUrl = item["google_search"]
      @googleMapRouteUrl = item["how_to_go"]
      @columns.push(columns[0])
    end
    messages   
  end

  def build_default_search_template
  end
  
  #ラインのmessage
  def reply_text(msg)
    [
      {
      type: "text",
      text: msg
      }
    ]
  end

  def reply_template
    [
      {
        type: "template",
        altText: @altText,
        template: 
        {
          type: @type,
          text: @altText,
          actions: @confirm_actions       
        }
      }
    ]
  end

  def confirm_actions
    [
      {   
        type: "postback",
        data: @post_id,
        label: @label
      }
    ]
  end

  def actions
    [
      {
        type: 'uri',
        label: 'この店情報へ',
        uri: @googleSearchUrl
      },
      {
        type: 'uri',
        label: 'ここからのルート',
        uri: @googleMapRouteUrl
      }
    ]
  end

  def columns
    [
      {
        title: @title,
        text: 'ここから'+@distance.to_s+'km - '+ @address,
        actions: actions
      }
    ]
  end

  def messages
    [
      {
        type: 'template',
        altText: '検索結果',
        template: {
          type: 'carousel',
          columns: @columns
        }
      }
    ]
  end

  def template_type
    ["carousel","confirm","buttons"]
  end
end
