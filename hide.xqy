xquery version "1.0-ml";
import module namespace twitter = "http://namespace.dscape.org/2009/twitter"
  at "lib/twitter.xqy";

(: id status in the database :)
(: as it's only a demo it's using a get request and credentials aren't on db :)
	let $username          := xdmp:get-request-field("username")
	let $password          := xdmp:get-request-field("password")
	let $id                := xdmp:get-request-field("id")
  return twitter:hide_status($username,$password,$id)
