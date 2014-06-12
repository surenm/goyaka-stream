var back, feed_items, goyakaRadioFeedUrl, player;

goyakaRadioFeedUrl = "https://graph.facebook.com/v2.0/187054981393266/feed?fields=comments.limit(1).summary(true),likes.limit(1).summary(true),link,message,picture,name&limit=10000";

feed_items = [];

angular.element(document).ready(function() {
    var app;
    angular.module('app', []);
    app = angular.module("app", []);
    app.filter("startFrom", function() {
        return function(input, start) {
            start = +start;
            return input.slice(start);
        };
    });
    return angular.bootstrap(document, ['app']);
});

window.fbAsyncInit = function() {
    var fetchPlayList, loadPlayList;
    FB.init({
        appId: "306005766228917",
        xfbml: true,
        version: "v2.0"
    });
    FB.getLoginStatus(function(response) {
        var at, uid;
        console.log("QWE");
        console.log(response);
        console.log(back);
        if (response.status === "connected") {
            uid = response.authResponse.userID;
            at = response.authResponse.accessToken;
            fetchPlayList(function() {});
            back.feed_items = feed_items;
        } else {
            FB.login(fetchPlayList);
        }
    });
    fetchPlayList = function(cb) {
        console.log("fetchPlayList");
        if (localStorage.feed_items) {
            feed_items = JSON.parse(localStorage.feed_items);
            back.feed_items = feed_items;
            return cb(feed_items);
        } else {
            loadPlayList(goyakaRadioFeedUrl, function(result) {
                feed_items = result;
                return console.log(feed_items.length);
            }, cb);
        }
    };
    return loadPlayList = function(url, loadFunction, cb) {
        return FB.api(url, function(result) {
            if (!result.data || result.data.length === 0) {
                localStorage.lastUpdated = new Date();
                localStorage.feed_items = JSON.stringify(feed_items);
                return console.log("Local val changed");
            } else {
                result.data = result.data.filter(function(item) {
                    return item.link;
                });
                result.data = _.map(result.data, function(item) {
                    item.m = item.message;
                    item.p = item.picture;
                    item.l = item.link;
                    item.i = item.id;
                    item.t = item.updated_time;
                    if (item.likes) {
                        item.u = item.likes.summary.total_count;
                    }
                    if (item.comments) {
                        item.c = item.comments.summary.total_count;
                    }
                    item = _.omit(item, ['updated_time', 'message', 'picture', "link", "id", "likes", "comments"]);
                    return item;
                });
                feed_items = feed_items.concat(result.data);
                loadFunction(feed_items);
                return loadPlayList(result.paging.next, loadFunction, cb);
            }
        });
    };
};

(function(d, s, id) {
    var fjs, js;
    js = void 0;
    fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) {
        return;
    }
    js = d.createElement(s);
    js.id = id;
    js.src = "//connect.facebook.net/en_US/sdk.js";
    fjs.parentNode.insertBefore(js, fjs);
})(document, "script", "facebook-jssdk");

window.mainController = function($scope) {
    $scope.errMessage = "";
    $scope.pageSize = 5;
    $scope.data = [];
    $scope.waiting = true;
    if (player && player.index) {
        $scope.song_index = player.index;
    } else {
        $scope.song_index = 0;
    }
    if (player && player.state) {
        $scope.state = player.state;
    } else {
        $scope.state = 0;
    }
    $scope.currentPage = Math.floor($scope.song_index / $scope.pageSize);
    $scope.$watch("song_index", function(oldVal, newVal) {
        $scope.currentPage = Math.floor($scope.song_index / $scope.pageSize);
    });
    $scope.numberOfPages = function() {
        return Math.ceil($scope.data.length / $scope.pageSize);
    };
    back.getFeeds(function(feed_items) {
        $scope.data = feed_items;
    });
    $scope.getCurrentItem = function() {
        console.log($scope.song_index);
        return window.feed_items[$scope.song_index];
    };
    $scope.sortByLike = function() {
        $scope.data = _.sortBy($scope.data, function(item) {
            var comments, likes;
            if (item["likes"]) {
                comments = 0;
                likes = 0;
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
        });
        back.feed_items = $scope.data;
    };
    $scope.getRowColor = function(index) {
        if ($scope.song_index === ($scope.currentPage * $scope.pageSize + index)) {
            return "bg-primary";
        }
    };
    $scope.stateCallback = function(code) {
        if (console) {
            $scope.$apply(function() {
                $scope.state = code;
            });
        }
    };
    $scope.changeCallback = function(new_index) {
        if (console) {
            $scope.song_index = player.index;
        }
    };
    $scope.errCallBack = function(err) {
        if (console) {
            if (err === 150 || err === "150") {
                $scope.$apply(function() {
                    $scope.errMessage = "This is song is not playable outside youtube.";
                });
            }
        }
    };
    $scope.getErrorClass = function(boolvar) {
        if (boolvar) {
            return "bg-danger";
        }
    };
    $scope.next = function() {
        player.playNext();
    };
    $scope.pause = function() {
        player.pauseVideo();
    };
    $scope.resume = function() {
        player.playVideo();
    };
    $scope.play = function(index) {
        $scope.errMessage = "";
        player.play($scope.currentPage * $scope.pageSize + index);
    };
    back.errCallBack = $scope.errCallBack;
    back.changeCallback = $scope.changeCallback;
    back.stateCallback = $scope.stateCallback;
};

if (parent === window) {
    back = chrome.extension.getBackgroundPage();
} else {
    back = parent;
}

player = back.player;
