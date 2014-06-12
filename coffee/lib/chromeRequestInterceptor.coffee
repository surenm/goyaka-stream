if chrome.extension
  chrome.webRequest.onBeforeSendHeaders.addListener ((info) ->
    
    #  Bypass YouTube's embedded player content restrictions by provided a value for Referer.
    refererRequestHeader = _.find(info.requestHeaders, (requestHeader) ->
      requestHeader.name is "Referer"
    )
    refererUrl = info.url.substring(0, info.url.indexOf("/embed/"))
    if _.isUndefined(refererRequestHeader)
      info.requestHeaders.push
        name: "Referer"
        value: refererUrl

    else
      refererRequestHeader.value = refererUrl
    userAgentRequestHeader = _.find(info.requestHeaders, (requestHeader) ->
      requestHeader.name is "User-Agent"
    )
    iPhoneUserAgent = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5"
    if userAgentRequestHeader is `undefined`
      info.requestHeaders.push
        name: "User-Agent"
        value: iPhoneUserAgent

    else
      userAgentRequestHeader.value = iPhoneUserAgent
    requestHeaders: info.requestHeaders
  ),
    
    #urls: ['*://*.youtube.com/embed/?enablejsapi=1&origin=chrome-extension%3A%2F%2Fjbnkffmindojffecdhbbmekbmkkfpmjd']
    urls: ["*://*.youtube.com/embed/?enablejsapi=1&origin=chrome-extension:\\\\"]
  , [
    "blocking"
    "requestHeaders"
  ]