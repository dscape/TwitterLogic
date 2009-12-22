xquery version "1.0-ml";
module namespace twitter = "http://namespace.dscape.org/2009/twitter";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: Finding any status containing the query :)
declare function twitter:find-by-screen-name($screen_name as xs:string) {
     cts:search(//*:screen_name, 
       cts:element-value-query(xs:QName("screen_name"),
         concat($screen_name, "*"),
         ("wildcarded", "case-insensitive") ) )
};

(: Get the friends timeline in xml format :)
declare function twitter:get-friends-timeline(
  $username as xs:string,
  $password as xs:string ) {
  try {
    xdmp:http-get( "http://twitter.com/statuses/friends_timeline.xml",
      <options xmlns="xdmp:http">
        <authentication method="basic">
          <username>{$username}</username>
          <password>{$password}</password>
         </authentication>
      </options>)
  } catch ($e) {
    document { <error>
		  Connection Problem
	  </error> }
  }
};

(: Checks for successful authentication :)
declare function twitter:auth-successful(
	$username as xs:string,
	$password as xs:string ) as xs:boolean {
	let $timeline := twitter:get-friends-timeline($username,$password)
	let $http_response_code := $timeline//*:code
	return not($http_response_code eq xs:integer('401'))
};

(: Loads new statuses into the database :)
declare function twitter:store-timeline(
  $username as xs:string,
  $password as xs:string ) {
  for $status in 
  (: doc()
  return
    xdmp:document-delete(document-uri($status)) :)
    twitter:get-friends-timeline($username,$password)/*:statuses/*:status
  let $uri := concat("./", $status/*:id/text(), ".xml")
  let $insert := xdmp:document-insert($uri, $status)
  let $collection := xdmp:document-add-collections($uri, $username) 
  return
    (: To avoid data not being loaded before displayed :)
    xdmp:sleep(100)
};

(: Get the timeline for a specific user :)
declare function twitter:get-timeline-for(
	$username as xs:string ) {
	(: implement later on with some kind of wildcard :)
	collection($username)
};

(: Send a tweet :)
declare function twitter:tweet(
  $username as xs:string,
  $password as xs:string,
  $message as xs:string  
) {
  try {
    xdmp:http-post( 
    "http://twitter.com/statuses/update.xml?status={xdmp:url-encode($message)}",
      <options xmlns="xdmp:http">
        <authentication method="basic">
          <username>{$username}</username>
          <password>{$password}</password>
         </authentication>
      </options>)
  } catch ($e) {
    document { 
    <error>
		  Connection Problem
	  </error> }
  }
};
