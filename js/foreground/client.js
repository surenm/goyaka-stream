var app = angular.module("qq", []);
var back = chrome.extension.getBackgroundPage();
var player = back.player;
var feed_items = back.feed_items;
var currentPlaying = 0;

function mainController($scope) {
    $scope.errMessage = "";
    $scope.pageSize = 5;
    $scope.data = [];
    $scope.waiting = true;
    if (player.index) {
        $scope.song_index = player.index;
    } else {
        $scope.song_index = 0;
    }
    if (player.state) {
        $scope.state = player.state;
    } else {
        $scope.state = 0;
    }
    $scope.currentPage = Math.floor($scope.song_index / $scope.pageSize);
    $scope.$watch('song_index', function(oldVal, newVal) {
        $scope.currentPage = Math.floor($scope.song_index / $scope.pageSize);
    })
    $scope.numberOfPages = function() {
        return Math.ceil($scope.data.length / $scope.pageSize);
    }
    back.getFeeds(function(feed_items) {
        $scope.data = feed_items;
    })
    $scope.sortByLike = function() {
        $scope.data = _.sortBy($scope.data, function(item) {
            if (item["likes"]) {
                var comments = 0;
                var likes = 0;
                if (item.comments) {
                    comments = item.comments.summary.total_count;
                }
                if (item.likes) {
                    likes = item.likes.summary.total_count;
                }

                return -1 * (comments * 5 + likes);
            } else {
                return 0;
            }
        })
        back.feed_items = $scope.data;
    }
    $scope.getRowColor = function(index) {
        if ($scope.song_index == ($scope.currentPage * $scope.pageSize + index)) {
            return "bg-primary";
        }
    }
    $scope.stateCallback = function(code) {
        if (console) {
            console.log("QWEWe");
            $scope.$apply(function() {
                $scope.state = code;
            });
        }
    }
    $scope.changeCallback = function(new_index) {
        if (console) {
            $scope.song_index = player.index;
        }
    }
    $scope.errCallBack = function(err) {
        if (console) {
            console.log("$scope error");
            if (err == 150 || err == "150") {
                console.log("WEC");
                console.log(err);
                $scope.$apply(function() {
                    $scope.errMessage = "This is song is not playable outside youtube.";
                });
            }
        }
    }
    $scope.getErrorClass = function(boolvar) {
        if (boolvar) {
            return "bg-danger";
        }
    }
    $scope.next = function() {
        player.playNext();
    }
    $scope.pause = function() {
        player.pauseVideo();
    }
    $scope.resume = function() {
        player.playVideo();
    }
    $scope.play = function(index) {
        $scope.currentPlaying = index
        $scope.errMessage = "";
        player.play($scope.currentPage * $scope.pageSize + index);
    }
    back.errCallBack = $scope.errCallBack;
    back.changeCallback = $scope.changeCallback;
    back.stateCallback = $scope.stateCallback;
}

app.filter('startFrom', function() {
    return function(input, start) {
        start = +start; //parse to int
        return input.slice(start);
    }
});
