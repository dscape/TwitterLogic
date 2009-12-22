xquery version "1.0-ml";
import module namespace twitter = "http://namespace.dscape.org/2009/twitter"
  at "lib/twitter.xqy";

(: autocomplete for username :)
  let $screen_name := xdmp:get-request-field("screen_name")
  let $screen_names := twitter:find-by-screen-name($screen_name)
  return <ul> {
    for $name in distinct-values($screen_names)
    return
      <li> { xs:string($name) }</li>
    } </ul>
