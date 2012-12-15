root = exports ? this

_prefixes =
  js: ["webkit", "moz", "MS", "o", ""]
  css: ["Webkit", "Moz", "ms", "O", ""]

_prefixCss = (attribute, callback) ->
  for prefix in _prefixes.css
    attribute = attribute.charAt(0).toLowerCase() + attribute.slice(1) unless prefix
    callback("#{prefix}#{attribute}")
  return

_prefixJs = (attribute, callback) ->
  for prefix in _prefixes.js
    attribute = attribute.toLowerCase() unless prefix
    callback("#{prefix}#{attribute}")
  return

# prepends attribute with the prefixes following the certain naming convention and for every prefixed version
# of the attribute calls the callback and passes prefixed attribute as an argument.
# 
# @param attribute String - attribute to be prefixed (in js there is a convention of using camelCase,
# so pass the attribute in this manner and don't bother yourself if the version without prefix needs to be "lowercased" - it will be.)
# @param callback Function - function to be called with the few versions of the prefixed attribute
# @param type String (css|js (def.)) - defines whether to use the css naming convention in js (e.g. OTransition)
# or the js events naming convention (e.g. oAnimationEnd)
#
# { @code
#   element = document.getElementById("foo")
#   # sets a css3 property using vendor-prefixed versions as well as the w3c's.
#   # (WebkitAnimationName, MozAnimationName, msAnimationName, OAnimationName, animationName)
#   prefixify "AnimationName", (prefixed) ->
#     element.style[prefixed] = "fade-in"
#   , "css"
# }
# { @code
#   element = document.getElementById("foo")
#   # adds event listeners for a css3 event using vendor-prefixed versions as well as the w3c's.
#   # (webkitAnimationEnd, mozAnimationEnd, MSAnimationEnd, oAnimationEnd, animationend)
#   prefixify "AnimationEnd", (prefixed) ->
#     element.addEventListener(prefixed, listener, false)
# }
root.prefixify = (attribute, callback, type) ->
  throw "prefixify requires callback" if typeof callback != "function"
  if type == "css"
    _prefixCss(attribute, callback)
  else
    _prefixJs(attribute, callback)
  return