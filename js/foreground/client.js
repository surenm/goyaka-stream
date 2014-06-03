var app = angular.module("qq", []);
var back = chrome.extension.getBackgroundPage();
var player = back.player;
var feed_items = back.feed_items;

function mainController($scope) {
    $scope.errMessage = "";
    $scope.errCallBack = function(err) {
        console.log("$scope error");
        if (err == 150 || err == "150") {
            console.log("WEC");
            console.log(err);
            $scope.$apply(function() {
                $scope.errMessage = "This is song is not playable outside youtube.";
            });
        }
    }
    back.errCallBack = $scope.errCallBack;
    $scope.currentPage = 0;
    $scope.pageSize = 10;
    $scope.data = [];
    $scope.waiting = true;
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
    }
    $scope.prev = function() {
        console.log("prev");
    }
    $scope.next = function() {
        player.loadVideoById()
    }
    $scope.toggle = function() {
        console.log("toggle");
    }
    $scope.play = function(index) {
        console.log("PLAY");
        $scope.errMessage = "";
        console.log($scope.currentPage)
        console.log($scope.pageSize)
        console.log(index)
        var videoId = getIdFromUrl(feed_items[$scope.currentPage * $scope.pageSize + index].link);
        console.log("QQE");
        console.log(videoId);
        if (videoId == null) {
            console.log("Not supported.");
        } else {
            player.loadVideoById(videoId);
        }
    }
}

var patt = /(youtu(?:\.be|be\.com)\/(?:.*v(?:\/|=)|(?:.*\/)?)([\w'-]+))/i;

var getIdFromUrl = function(url) {
    var ret = patt.exec(url);
    console.log(ret);
    if (ret.length >= 3) {
        return (patt.exec(url)[2]);
    } else {
        return null;
    }
}

app.filter('startFrom', function() {
    return function(input, start) {
        start = +start; //parse to int
        return input.slice(start);
    }
});
