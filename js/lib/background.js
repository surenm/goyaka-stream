var access_token_url = "https://graph.facebook.com/oauth/access_token?client_id=303369369825890&client_secret=4bbe29c93ca31dfc8f116a9a4e3de670&grant_type=client_credentials";
var goyakaRadioFeedUrl = "https://graph.facebook.com/v2.0/187054981393266/feed";
var FB_APP_ID = 303369369825890;
var feed_items = [];
var errCallBack;


var access_token;

function getFeeds(cb) {
    console.log("QWEWQWQE")
    console.log(feed_items);
    if (feed_items.length === 0) {
        console.log("######3E")
        chrome.storage.local.get(["lastUpdated", "feed_items"], function(items) {
            var lastUpdated = items.lastUpdated;
            console.log(items);
            if (lastUpdated === undefined) {
                $.get(access_token_url, function(result) {
                    access_token = result.split("=")[1];
                    refetchWholeList(cb);
                });
            } else {
                feed_items = items.feed_items;
                console.log(feed_items.length);
                feed_items = feed_items.filter(function(item) {
                    return item.link;
                });
                console.log(feed_items.length);
                cb(feed_items);
            }
        });
    } else {
        cb(feed_items);
    }

}

var refetchWholeList = function(cb) {
    loadPlayList(goyakaRadioFeedUrl, cb, function() {
        console.log("Loading done");
        feed_items = feed_items.filter(function(item) {
            return item.link;
        });
        cb(feed_items);
    });
};

function loadPlayList(url, loadFunction, cb) {
    $.get(url, {
        access_token: access_token,
    }, function(result) {
        if (result.data.length === 0) {
            chrome.storage.local.set({
                'lastUpdated': new Date(),
                'feed_items': feed_items
            }, function() {
                console.log("Local val changed");
                cb(feed_items);
            });
        } else {
            result.data = result.data.filter(function(item) {
                return item.link;
            });
            feed_items = feed_items.concat(result.data);
            loadFunction(feed_items);
            loadPlayList(result.paging.next, cb, cb);
        }
    });
}

getFeeds(function() {});
//chrome.storage.local.get(null,function(items){console.log(items)});

function youtubeError(error) {
    console.log(error);
    console.log("error");
    if (errCallBack) {
        console.log("Calln callback");
        errCallBack(error.data);
    }
}

function youtubeStageChange(event) {
    console.log(event);
    console.log("change");
}
