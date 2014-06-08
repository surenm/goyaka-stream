callPlayer = (func, args) ->
  frame_id = frame_id.get(0).id  if window.jQuery and frame_id instanceof jQuery
  iframe = document.getElementById(frame_id)
  iframe = iframe.getElementsByTagName("iframe")[0]  if iframe and iframe.tagName.toUpperCase() isnt "IFRAME"
  if iframe
    iframe.contentWindow.postMessage JSON.stringify(
      event: "command"
      func: func
      args: args or []
      id: frame_id
    ), "*"
  return
getFrameID = (id) ->
  elem = document.getElementById(id)
  if elem
    return id  if /^iframe$/i.test(elem.tagName) #Frame, OK
    # else: Look for frame
    elems = elem.getElementsByTagName("iframe")
    return null  unless elems.length #No iframe found, FAILURE
    i = 0

    while i < elems.length
      break  if /^https?:\/\/(?:www\.)?youtube(?:-nocookie)?\.com(\/|$)/i.test(elems[i].src)
      i++
    elem = elems[i] #The only, or the best iFrame
    return elem.id  if elem.id #Existing ID, return it
    # else: Create a new ID
    loop #Keep postfixing `-frame` until the ID is unique
      id += "-frame"
      break unless document.getElementById(id)
    elem.id = id
    return id
  
  # If no element, return null.
  null

# @param func function     Function to execute on ready
#     * @param func Boolean      If true, all qeued functions are executed
#     * @param b_before Boolean  If true, the func will added to the first
#                                 position in the queue

# Removes the first func from the array, and execute func
onYouTubePlayerAPIReady = ->
  YT_ready true
  return
window.player = undefined
frame_id = "iframeDiv"
window.state = undefined
YT_ready = (->
  onReady_funcs = []
  api_isReady = false
  (func, b_before) ->
    if func is true
      api_isReady = true
      onReady_funcs.shift()()  while onReady_funcs.length
    else if typeof func is "function"
      if api_isReady
        func()
      else
        onReady_funcs[(if b_before then "unshift" else "push")] func
    return
)()
(->
  s = document.createElement("script")
  s.src = ((if location.protocol is "https:" then "https" else "https")) + "://www.youtube.com/player_api"
  before = document.getElementsByTagName("script")[0]
  before.parentNode.insertBefore s, before
  return
)()
YT_ready ->
  frameID = getFrameID("tabs2")
  if frameID #If the frame exists
    window.player = new YT.Player(frameID,
      events:
        onStateChange: youtubeStageChange
        onError: youtubeError
    )
    console.log "Player ready"
    console.log window
    window.player_ready player
  return
