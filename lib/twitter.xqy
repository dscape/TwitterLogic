xquery version "1.0-ml";
module namespace twitter = "http://namespace.dscape.org/2009/twitter";
declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: Finding any status containing the query :)
declare function twitter:find-status($query as xs:string) as element(SPEECH)* {
     cts:search(//SPEECH, cts:element-value-query(xs:QName("SPEAKER"),$query, ("wildcarded", "case-insensitive")))	
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
    twitter:get-friends-timeline($username,$password)/*:statuses/*:status
    return 
      xdmp:document-insert(
       concat("friend_status_for_", $username, "_id_", $status/*:id, ".xml"), $status ) 
};

(: Get the timeline for a specific user :)
declare function twitter:get-timeline-for(
	$username as xs:string ) {
	(: implement later on with some kind of wildcard :)
	doc()
};
