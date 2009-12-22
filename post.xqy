xquery version "1.0-ml";
import module namespace twitter = "http://namespace.dscape.org/2009/twitter"
  at "lib/twitter.xqy";

(: post status and save it to database :)
(: as it's only a demo it's using a get request and credentials aren't on db :)
	let $username          := xdmp:get-request-field("username")
	let $password          := xdmp:get-request-field("password")
	let $status            := xdmp:get-request-field("status")
  return twitter:tweet($username,$password,$status)
