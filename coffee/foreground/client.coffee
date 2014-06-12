#Bootstrap angular
angular.element(document).ready ->
  angular.module 'app', []
  app = window.angular.module "app", [] 
  app.filter "startFrom", ->
    (input, start) ->
      start = +start #parse to int
      input.slice start
  angular.bootstrap document, ['app']

#Graph API prefix
graph_api_prefix = "https://graph.facebook.com/v2.0/"

window.mainController = ($scope,$http) ->
  $scope.errMessage = ""
  $scope.pageSize = 5
  $scope.data = []
  $scope.waiting = true
  $scope.song_index = 0

  $scope.currentPage = Math.floor($scope.song_index / $scope.pageSize)
  $scope.$watch "song_index", (oldVal, newVal) ->
    $scope.currentPage = Math.floor($scope.song_index / $scope.pageSize)
    $scope.getFBData()
    return

  $scope.getFBData = ->
    id = $scope.getCurrentItem().id
    url = graph_api_prefix + id + "?access_token=" + back.access_token
    promise = $http 
      url : url
      method : "GET"
    promise.success (data)->
      $scope.currentData = data

  if player and player.index
    $scope.song_index = player.index
  else
    $scope.song_index = 0
  if player and player.state
    $scope.state = player.state
  else
    $scope.state = 0
  $scope.numberOfPages = ->
    Math.ceil $scope.data.length / $scope.pageSize

  back.getFeeds (feed_items) ->
    $scope.data = feed_items
    return

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
    $scope.song_index = player.index  if console
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
    player.playNext()
    return

  $scope.pause = ->
    player.pauseVideo()
    return

  $scope.resume = ->
    player.playVideo()
    return

  $scope.play = (index) ->
    $scope.errMessage = ""
    player.play $scope.currentPage * $scope.pageSize + index
    return

  back.errCallBack = $scope.errCallBack
  back.changeCallback = $scope.changeCallback
  back.stateCallback = $scope.stateCallback
  return

window.back = chrome.extension.getBackgroundPage()
window.player = window.back.player
window.feed_items = window.back.feed_items
