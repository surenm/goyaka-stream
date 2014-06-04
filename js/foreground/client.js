var app = angular.module("qq", []);
var back = chrome.extension.getBackgroundPage();
var player = back.player;
var feed_items = back.feed_items;
var currentPlaying = 0;

function mainController($scope) {
    $scope.errMessage = "";
    $scope.pageSize = 10;
    $scope.data = [];
    $scope.waiting = true;
    if (player.index) {
        $scope.song_index = player.index;
    } else {
        $scope.song_index = 0;
    }
    $scope.state;
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
                return item.likes.data.length;
            } else {
                return 0;
            }
        })
        back.feed_items = $scope.data;
    }
    $scope.changeCallback = function(new_index) {
        if (console) {
            console.log("CHAZ");
            console.log(new_index);
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
    $scope.next = function() {
        player.playNext();
    }
    $scope.toggle = function() {
        console.log("toggle");
    }
    $scope.play = function(index) {
        $scope.currentPlaying = index
        $scope.errMessage = "";
        player.play($scope.currentPage * $scope.pageSize + index);
    }
    back.errCallBack = $scope.errCallBack;
    back.changeCallback = $scope.changeCallback;
}

app.filter('startFrom', function() {
    return function(input, start) {
        start = +start; //parse to int
        return input.slice(start);
    }
});
