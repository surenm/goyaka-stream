access_token_url = "https://graph.facebook.com/oauth/access_token?client_id=303369369825890&client_secret=4bbe29c93ca31dfc8f116a9a4e3de670&grant_type=client_credentials"
goyakaRadioFeedUrl = "https://graph.facebook.com/v2.0/187054981393266/feed?fields=comments.limit(1).summary(true),likes.limit(1).summary(true),link,message,picture,name"
FB_APP_ID = 303369369825890
access_token = undefined
window.errCallBack = undefined
window.changeCallback = undefined
window.stateCallback = undefined
window.feed_items = []

#chrome.storage.local.get(null,function(items){console.log(items)});

window.getPlayer = ->
  return player

window.youtubeError = (error) ->
  console.log error
  console.log "error"
  window.feed_items[window.player.index].error = true
  console.log window.player.index
  console.log window.feed_items[window.player.index]
  if errCallBack
    console.log "Calln callback"
    errCallBack error.data
  window.player.playNext()
  return
window.youtubeStageChange = (event) ->
  console.log event
  console.log "change"
  window.player.state = event.data
  stateCallback event.data  if stateCallback
  window.player.playNext()  if event.data is 0
  return

window.player_ready =  (player) ->
  window.player = player
  window.player.playNext = ->
    @index++
    window.player.play @index
    return

  window.player.play = (index) ->
    @index = index
    id = getIdFromUrl(window.feed_items[index].l)
    if changeCallback
      console.log "ZZZZZZZ"
      console.log index
      changeCallback (index)
    console.log "QWERT"
    if id
      window.player.loadVideoById id
    else
      youtubeError data: 150
    return

  return

window.getAccessTokenFromURL = (url) ->
  window.access_token = getParameterByName(url,"#access_token")

window.getParameterByName = (url,name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
  results = regex.exec(url)
  (if not results? then "" else decodeURIComponent(results[1].replace(/\+/g, " ")))

getIdFromUrl = (url) ->
  patt = /(youtu(?:\.be|be\.com)\/(?:.*v(?:\/|=)|(?:.*\/)?)([\w'-]+))/i
  ret = patt.exec(url)
  console.log ret
  if ret and ret.length and ret.length >= 3
    patt.exec(url)[2]
  else
    null
