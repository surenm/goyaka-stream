goyakaRadioFeedUrl = "https://graph.facebook.com/v2.0/187054981393266/feed?fields=comments.limit(1).summary(true),likes.limit(1).summary(true),link,message,picture,name&limit=10000"
webAuthFlowUrl = "https://www.facebook.com/dialog/oauth?client_id=1494525657425885&redirect_uri=" + 'https://' + chrome.runtime.id + '.chromiumapp.org/provider_cb' +"&response_type=token"

back = chrome.extension.getBackgroundPage()

accessToken = back.accessToken
if not accessToken
  options = 
    url : webAuthFlowUrl
    interactive : true
  console.log options
  chrome.identity.launchWebAuthFlow options ,(data)->
    back.console.log data
    back.getAccessTokenFromURL data

#Short names for saving space while stroing in local

# item.m = item.message
# item.p = item.picture
# item.l = item.link
# item.i = item.id
# item.t = item.updated_time

#Bootstrap angular
angular.element(document).ready ->
  angular.module 'app', []
  app = angular.module "app", [] 
  app.filter "startFrom", ->
    (input, start) ->
      start = +start #parse to int
      input.slice start
  angular.bootstrap document, ['app']

window.mainController = ($scope,$http) ->
  $scope.errMessage = ""
  $scope.pageSize = 5
  $scope.data = []
  $scope.waiting = true

  $scope.fetchPlayList = (cb) ->
    console.log "fetchPlayList"
    if localStorage.feed_items
      $scope.data = JSON.parse(localStorage.feed_items)
      back.feed_items = $scope.data
      cb $scope.data
    else
      $scope.loadPlayList goyakaRadioFeedUrl, (result)->
        $scope.data = result
        console.log $scope.data.length
      ,cb
      return

  $scope.loadPlayList = (url, loadFunction, cb) ->
    console.log back.access_token
    promise = $http 
      url : url + "&access_token=" + back.access_token
      method : "GET"
    promise.success (result) ->
      if !result.data || result.data.length is 0
        localStorage.lastUpdated = new Date()
        localStorage.feed_items = JSON.stringify $scope.data
        console.log "Local val changed"
      else
        result.data = result.data.filter((item) ->
          item.link
        )
        result.data = _.map result.data, (item) ->
          item.m = item.message
          item.p = item.picture
          item.l = item.link
          item.i = item.id
          item.t = item.updated_time
          if item.likes
            item.u = item.likes.summary.total_count
          if item.comments
            item.c = item.comments.summary.total_count
          item = _.omit item,['updated_time','message','picture',"link","id","likes","comments"]
          return item
        $scope.data = $scope.data.concat(result.data)
        loadFunction $scope.data
        $scope.loadPlayList result.paging.next, loadFunction, cb

  $scope.fetchPlayList ->
    console.log "Loading DONE"

  if back.getPlayer() and back.getPlayer().index
    $scope.song_index = getPlayer().index
  else
    $scope.song_index = 0
  if back.getPlayer() and back.getPlayer().state
    $scope.state = getPlayer().state
  else
    $scope.state = 0
  $scope.currentPage = Math.floor($scope.song_index / $scope.pageSize)
  $scope.$watch "song_index", (oldVal, newVal) ->
    $scope.currentPage = Math.floor($scope.song_index / $scope.pageSize)
    return

  $scope.numberOfPages = ->
    Math.ceil $scope.data.length / $scope.pageSize

  $scope.getCurrentItem = ->
    console.log $scope.song_index
    return window.feed_items[$scope.song_index]

  $scope.sortByLike = ->
    $scope.data = _.sortBy($scope.data, (item) ->
      if item["likes"]
        comments = 0
        likes = 0
        comments = item.comments.summary.total_count  if item.comments
        likes = item.likes.summary.total_count  if item.likes
        -1 * (comments * 5 + likes)
      else
        0
    )
    back.feed_items = $scope.data
    return

  $scope.getRowColor = (index) ->
    "bg-primary"  if $scope.song_index is ($scope.currentPage * $scope.pageSize + index)

  $scope.stateCallback = (code) ->
    if console
      $scope.$apply ->
        $scope.state = code
        return

    return

  $scope.changeCallback = (new_index) ->
    $scope.song_index = getPlayer().index  if console
    return

  $scope.errCallBack = (err) ->
    if console
      if err is 150 or err is "150"
        $scope.$apply ->
          $scope.errMessage = "This is song is not playable outside youtube."
          return

    return

  $scope.getErrorClass = (boolvar) ->
    "bg-danger"  if boolvar

  $scope.next = ->
    getPlayer().playNext()
    return

  $scope.pause = ->
    getPlayer().pauseVideo()
    return

  $scope.resume = ->
    getPlayer().playVideo()
    return

  $scope.play = (index) ->
    $scope.errMessage = ""
    back.getPlayer().play $scope.currentPage * $scope.pageSize + index
    return

  back.errCallBack = $scope.errCallBack
  back.changeCallback = $scope.changeCallback
  back.stateCallback = $scope.stateCallback
  return
