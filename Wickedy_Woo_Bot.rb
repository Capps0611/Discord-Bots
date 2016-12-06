require 'discordrb'
require 'net/http'
require 'mechanize'

def bot_join(aBot,aEvent)
    c = aEvent.user.voice_channel
    aBot.voice_connect(c)
    return c
end
bot = Discordrb::Bot.new token: 'MjQ4MjEwODgxNzg2MTUwOTEz.Cw0b7A.o3EnOGtkGuHMmN9TPuNGm8vRxvU', client_id: 248210881786150913

isPlaying = false
#Pasts the link to invite the bot to a server!
puts "This bot's invite URL is #{bot.invite_url}."
puts 'Click on it to invite it to your server.'


#Regx that will get (Link to Log) and (Name Of Log) : <td><a href="(.+)">(\w.+)<\/a>
bot.message(with_text: '!WW_Bot_Info') do |event|
  event.respond 'Hi server! I\'m the Wickedy Woo Info Bot! I provide tons of helpful info! Type !WW_Commands to see what I can do!'
end

#Pastes the last 8 Raid Logs to chat!
bot.message(with_text: '!WW_Logs') do |event|
#  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  uri = URI('https://www.warcraftlogs.com/guilds/reportslist/57022')
  source = Net::HTTP.get(uri)
  logs_re = %r|<td><a href="(.+)">(\w.+)<\/a>|
  logs = source.scan(logs_re)
#  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_PEER

  $i = 0
  logs.each do |line|
  	log_link = line[0]
    log_name = line[1]
    complete_log = log_name+': https://www.warcraftlogs.com'+log_link
    if $i == 8
      break
    end
    $i = $i+1
    event.respond complete_log
  end
end

#Displays Raid Days/Times
bot.message(with_text: '!WW_Raid_Days') do |event|
  event.respond 'Wickedy Woo\'s Raid Days are:'
  event.respond 'Tuesday & Wednesday @ 7:30pm EST - 10:30pm EST'
end

#Displays Wickedy Woo Staff
bot.message(with_text: '!WW_Staff') do |event|
  event.respond 'Guild Master: Capps'
  event.respond 'Grand Woofficers: Ctdemonet, Rageapples, Yikesa'
  event.respond 'Woofficers: Krazzed, Trollgwild, Disaa, Precedent, Beebop, Alecto, Crysus, Yartch, Schottky, Tribalpopoki'
  event.respond 'Raid Leader: Capps'
end

#Displays Wickedy Woo Twitch Streams!
bot.message(with_text: '!WW_Streamers') do |event|
    event.respond 'Capps- https://www.twitch.tv/Capps_tv'
    event.respond 'Disaa - https://www.twitch.tv/hevisdead'
    event.respond 'Capps & Disaa - http://multitwitch.tv/capps_tv/hevisdead'
end

#Displays All commands the bot can do!
bot.message(with_text: '!WW_Commands') do |event|
  event.respond 'List of Commands:'
  event.respond '!WW_Logs - List link to past 8 raid logs in chat!'
  event.respond '!WW_Staff - Lists the GM & Officers of Wickedy Woo!'
  event.respond '!WW_Raid_Days - Lists Wickedy Woo\'s Raid Days/Times!'
  event.respond '!WW_Streamers - Lists Wickedy Woo\'s Twitch streams!'
  event.respond '!WW_Bot_Info - Displays bot welcome text!'.
  event.respond 'Have a command request? I\'ll see what I can do!'
end

bot.message(with_text: '!Odyn') do |event|
#    channel = event.user.voice_channel
#    bot.voice_connect(channel)
    aChannel = bot_join(bot,event)
    voice_bot = event.voice
    voice_bot.play_file('/root/Odyn_Explanation.mp3')
    bot.voice_destroy(aChannel,true)
end

#Music bot - WIP
#For downloading the music file use youtube-dl --extract-audio --audio-format mp3 -o "%(title)s.%(ext)s" URL
#Make sure only one song plays at a time, make a que?
bot.message(containing: ("!WW_Radio")) do |event|
    msg = event.content #gets message from user
    requester = event.user.username
    if isPlaying == false
  	      isPlaying = true
          song_url = msg.sub(/!WW_Radio/,'' ) #removes !WW_Radio, ready to eventually use to get url for mp3 downloads
          #event.respond song_url #for debug only until download and play works
          cmd = "youtube-dl --extract-audio --audio-quality 176 -o 'song.%(ext)s' "+song_url
        	system(cmd)
        	system("ls >> list.txt")
        	aFile = File.open('list.txt')
        	songToPlay = ''
        	aFile.each do |line|
        	    if line.match(/song.\w+/)
        		      songToPlay = line
        		        break
        	    end
        	end
        	aFile.close
        	system("rm list.txt")
          event.respond 'Playing the song requested by '+requester+'!'
            #    channel = event.user.voice_channel
            #    bot.voice_connect(channel)
        	aChannel = bot_join(bot,event)
          voice_bot = event.voice
        	#plays file depending on extension
        	if songToPlay.match(/song.ogg/)
        	    voice_bot.play_file('/root/song.ogg')
        	end
        	if songToPlay.match(/song.m4a/)
        	    voice_bot.play_file('/root/song.m4a')
        	end
        	if songToPlay.match(/song.mp3/)
        	    voice_bot.play_file('/root/song.mp3')
        	end
          bot.voice_destroy(aChannel,true)
          system("rm "+songToPlay)
        	isPlaying = false
    else
	     event.respond 'Sorry '+requester+' a song is already playing please try again later!'
    end
end

#runs bot
bot.run
