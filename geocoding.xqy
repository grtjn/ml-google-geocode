xquery version "1.0-ml";

module namespace geo = "http://marklogic.com/geocoding";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare variable $memcache as map:map := map:map();

declare function geo:geocode($address as xs:string) as element(GeocodeResponse)? {
  let $geocode := geo:getFromCache($address)
  return
  if ($geocode) then (
    xdmp:log(concat("Pulled ", $address, " from cache")),
    $geocode
  ) else
    let $geocode := geo:get($address)
    return
    if ($geocode) then (
      xdmp:log(concat("Retrieved ", $address, " from Google")),
      geo:putInCache($address, $geocode),
      $geocode
    ) else (
      xdmp:log(concat("Retrieving ", $address, " from Google failed"))
    )
};

declare function geo:persistCache() {
  for $uri in map:keys($memcache)
  return (
    xdmp:log(concat("Persisting ", $uri, " to database..")),
    xdmp:document-insert($uri, map:get($memcache, $uri))
  )
};

declare private function geo:get($address as xs:string) as element(GeocodeResponse)? {
  let $response :=
    try {
      let $response :=
        xdmp:http-get(concat(
          "http://maps.googleapis.com/maps/api/geocode/xml?address=",
          encode-for-uri($address)
        ))[2]
      let $_ := xdmp:sleep(250) (: rate-limited to 5 per sec, 2500 per day.. :)
      return
        $response
    } catch ($e) {
      xdmp:log($e)
    }
  return
    if ($response/GeocodeResponse/status = 'OK') then
      $response/GeocodeResponse
    else if ($response/GeocodeResponse/status = 'OVER_QUERY_LIMIT') then
      error(xs:QName("OVER_QUERY_LIMIT"), "The daily quota has been exhausted, bailing out. Try again tomorrow (seriously)..")
    else
      xdmp:log($response)
};

declare private function geo:getFromCache($address as xs:string) as element(GeocodeResponse)? {
  let $uri := concat("/geocache/", encode-for-uri(encode-for-uri($address)), ".xml")
  let $inmem := map:get($memcache, $uri)
  return
  if ($inmem) then
    $inmem
  else
    doc($uri)/GeocodeResponse
};

declare private function geo:putInCache($address as xs:string, $geocode as element(GeocodeResponse)) as empty-sequence() {
  let $uri := concat("/geocache/", encode-for-uri(encode-for-uri($address)), ".xml")
  return
    map:put($memcache, $uri, $geocode)
};

