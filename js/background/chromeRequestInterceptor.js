chrome.webRequest.onBeforeSendHeaders.addListener(function(info) {
    console.log("QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");
    //  Bypass YouTube's embedded player content restrictions by provided a value for Referer.
    var refererRequestHeader = _.find(info.requestHeaders, function(requestHeader) {
        return requestHeader.name === 'Referer';
    });

    var refererUrl = info.url.substring(0, info.url.indexOf('/embed/'));

    if (_.isUndefined(refererRequestHeader)) {
        info.requestHeaders.push({
            name: 'Referer',
            value: refererUrl
        });
    } else {
        refererRequestHeader.value = refererUrl;
    }

    var userAgentRequestHeader = _.find(info.requestHeaders, function(requestHeader) {
        return requestHeader.name === 'User-Agent';
    });

    var iPhoneUserAgent = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5';
    if (userAgentRequestHeader === undefined) {
        info.requestHeaders.push({
            name: 'User-Agent',
            value: iPhoneUserAgent
        });
    } else {
        userAgentRequestHeader.value = iPhoneUserAgent;
    }
    return {
        requestHeaders: info.requestHeaders
    };
}, {
    //urls: ['*://*.youtube.com/embed/?enablejsapi=1&origin=chrome-extension%3A%2F%2Fjbnkffmindojffecdhbbmekbmkkfpmjd']
    //  Match on my specific iframe or else else this logic can leak into outside webpages and corrupt other YouTube embeds.
    urls: ['*://*.youtube.com/embed/?enablejsapi=1&origin=chrome-extension:\\\\dfklmejdccbihlkdiniadcjolihldomk']
}, ['blocking', 'requestHeaders']);
