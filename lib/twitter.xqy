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
	return $http_response_code eq xs:integer('200')
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
  let $uri := twitter:uri_for($status/*:id/text())
  let $insert := xdmp:document-insert($uri, $status)
  let $collection := xdmp:document-add-collections($uri, $username) 
  return
    () 
};

(: Get the timeline for a specific user :)
declare function twitter:get-timeline-for(
	$username as xs:string) {
	  collection($username)
};

(: Get the filtered timeline for a specific user :)
declare function twitter:get-filtered-timeline-for(
	$username as xs:string,
	$filter as xs:string ) {
     cts:search(collection($username)[//*:screen_name], 
       cts:element-value-query(xs:QName("screen_name"),
         $filter,
         ("wildcarded", "case-insensitive") ) )
};

(: Delete a tweet :)
declare function twitter:delete_status(
  $username as xs:string,
  $password as xs:string,
  $status_id as xs:string  
) {
  try {
    let $options := 
      <options xmlns="xdmp:http">
        <authentication method="basic">
          <username>{$username}</username>
          <password>{$password}</password>
         </authentication>
      </options>
    let $delete := xdmp:document-delete(twitter:uri_for($status_id))
    let $post   := xdmp:http-delete( 
      concat("http://twitter.com/statuses/destroy/",$status_id,".xml"), $options)
    let $reload_statuses :=  twitter:store-timeline($username,$password)
    let $response_code := $post//*:code
    return if($response_code eq xs:integer('200'))
      then 
        xdmp:redirect-response(concat("/?username=",$username,"&amp;password=",$password,"&amp;notice=",xdmp:url-encode('Status deleted')))
      else
        xdmp:redirect-response(concat("/?username=",$username,"&amp;password=",$password,"&amp;error=",xdmp:url-encode('Delete Failed')))
  } catch ($e) {
    xdmp:redirect-response(concat("/?username=",$username,"&amp;password=",$password,"&amp;error=",xdmp:url-encode(xdmp:quote($e))))
  }
};

(: Send a tweet :)
declare function twitter:tweet(
  $username as xs:string,
  $password as xs:string,
  $message as xs:string  
) {
  try {
    let $options := 
      <options xmlns="xdmp:http">
        <authentication method="basic">
          <username>{$username}</username>
          <password>{$password}</password>
         </authentication>
      </options>
    let $post   := xdmp:http-post( 
      concat("http://twitter.com/statuses/update.xml?status=",xdmp:url-encode($message)), $options)
    let $response_code := $post//*:code
    let $uri := twitter:uri_for($post/*:id/text())
    let $insert := xdmp:document-insert($uri, $post)
    let $reload_statuses :=  twitter:store-timeline($username,$password)
    return if($response_code eq xs:integer('200'))
      then 
        xdmp:redirect-response(concat("/?username=",$username,"&amp;password=",$password,"&amp;notice=",xdmp:url-encode('Tweet posted')))
      else
        xdmp:redirect-response(concat("/?username=",$username,"&amp;password=",$password,"&amp;error=",xdmp:url-encode('Tweet failed')))
  } catch ($e) {
    xdmp:redirect-response(concat("/?username=",$username,"&amp;password=",$password,"&amp;error=",xdmp:url-encode(xdmp:quote($e))))
  }
};

(: Hide a tweet :)
declare function twitter:hide_status(
  $username as xs:string,
  $password as xs:string,
  $status_id as xs:string  
) {
  try {
    let $hide := xdmp:node-replace(doc(twitter:uri_for($status_id))/*:status/*:text, <text>******</text>)
    return 
      xdmp:redirect-response(concat("/?username=",$username,"&amp;password=",$password,"&amp;notice=",xdmp:url-encode("Status is now hidden")))
  } catch ($e) {
      xdmp:redirect-response(concat("/?username=",$username,"&amp;password=",$password,"&amp;error=",xdmp:url-encode(xdmp:quote($e))))
  }
};

(: The URI for a status :)
declare function twitter:uri_for(
  $status_id as xs:string
) {
  concat("./", $status_id, ".xml")
};
