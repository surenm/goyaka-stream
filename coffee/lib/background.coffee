goyakaRadioFeedUrl = "https://graph.facebook.com/v2.0/187054981393266/feed?fields=comments.limit(1).summary(true),likes.limit(1).summary(true),link,message,picture,name&limit=10000"
webAuthFlowUrl = "https://www.facebook.com/dialog/oauth?client_id=1494525657425885&redirect_uri=" + 'https://' + chrome.runtime.id + '.chromiumapp.org/provider_cb' +"&response_type=token"

FB_APP_ID = 1494525657425885
window.access_token = undefined
window.feed_items = []
window.errCallBack = undefined
window.changeCallback = undefined
window.stateCallback = undefined
window.feed_items = []

window.fetch_access_token = (cb)->
  options = 
    url : webAuthFlowUrl
    interactive : true
  console.log options
  chrome.identity.launchWebAuthFlow options ,(data)->
    console.log data
    getAccessTokenFromURL data
    cb()

window.getFeeds = (cb) ->
  if window.feed_items.length is 0
    chrome.storage.local.get [
      "lastUpdated"
      "feed_items"
    ], (items) ->
      lastUpdated = items.lastUpdated
      console.log items
      if lastUpdated is `undefined`
        fetch_access_token (result) ->
          console.log cb
          refetchWholeList cb
          return
      else
        window.feed_items = items.feed_items
        console.log window.feed_items.length
        window.feed_items = window.feed_items.filter((item) ->
          item.link
        )
        console.log window.feed_items.length
        cb window.feed_items
      return
  else
    cb window.feed_items
  return

loadPlayList = (url, loadFunction, cb) ->
  window.feed_items = window.feed_items
  $.get url,
    access_token: access_token
  , (result) ->
    if result.data.length is 0
      chrome.storage.local.set
        lastUpdated: new Date()
        feed_items: feed_items
      , ->
        console.log "Local val changed"
        cb window.feed_items
        return
    else
      result.data = result.data.filter((item) ->
        item.link
      )
      window.feed_items = window.feed_items.concat(result.data)
      loadFunction window.feed_items
      loadPlayList result.paging.next, cb, cb
    return
  return


#chrome.storage.local.get(null,function(items){console.log(items)});
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
    id = getIdFromUrl(window.feed_items[index].link)
    changeCallback index
    if id
      window.player.loadVideoById id
    else
      youtubeError data: 150
    return

  return

refetchWholeList = (cb) ->
  loadPlayList goyakaRadioFeedUrl, cb, ->
    console.log "Loading done"
    window.feed_items = window.feed_items.filter((item) ->
      item.link
    )
    cb window.feed_items
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

getFeeds (cb) -> return