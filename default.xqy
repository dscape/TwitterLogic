xquery version "1.0-ml";
import module namespace twitter = "http://namespace.dscape.org/2009/twitter"
  at "lib/twitter.xqy";
xdmp:set-response-content-type('text/html'),
('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	<head>
		<title>Twitter</title>
		<link rel="stylesheet" href="css/shared.css" type="text/css"/>
		<link rel="stylesheet" href="css/scriptaculous.css" type="text/css"/>
		<script src="js/prototype.js"></script>
    <script src="js/scriptaculous.js"></script>
	</head>
	<body>
	  <div id="container"> { 
	  let $username          := xdmp:get-request-field("username")
	  let $password          := xdmp:get-request-field("password")
	  let $filter            := xdmp:get-request-field("screen_name")
	  let $notice            := xdmp:get-request-field("notice")
	  let $error             := xdmp:get-request-field("error")
	  let $friends_timeline  := twitter:store-timeline($username,$password)
	  let $sleep             := xdmp:sleep(1000)
    let $auth_successful   := twitter:auth-successful($username,$password)
	  return 
	    if ($auth_successful)
	    then 
	    <div id="statuses_container">
	      <h1>Welcome to Twitter - { $username } </h1>
	      <div id="flash"> {
	        for $flash in ($error,$notice)
	        return <div class="flash">{$flash}</div> }
	      </div>
	      <div id="filter">
	        <form method="post" action="default.xqy">
      		  <div id="filter_status">
    	  	    <label>Filter by user</label>
	    	      <input type="text" name="screen_name" id="screen_name" />
	    	      <input type="text" name="username" id="username" value="{$username}" class="invisible"/>
	    	      <input type="text" name="password" id="password" value="{$password}" class="invisible"/>
	      	  </div>
	      	  <div id="filter_submit">
  		        <label class="invisible">Filter</label>
	  	        <input type="submit" name="filter_status" id="filter_status" 
	  	               value="Filter"/>
	    	    </div>
	      	</form>
	        <div id="auto_complete_opts" class="autocomplete"></div>
	    	  <script type="text/javascript">
            new Ajax.Autocompleter("screen_name", "auto_complete_opts",                
              "autocompleter.xqy", {{}});
          </script> 
	      </div> 
	      <div id="whats_happening">
	        <form method="post" action="post.xqy">
    		    <div id="whats_happening_status">
    		      <label>What's Happening?</label>
	    	      <input type="text" name="status" id="status" />
	    	      <input type="text" name="username" id="username" value="{$username}" class="invisible"/>
	    	      <input type="text" name="password" id="password" value="{$password}" class="invisible"/>
	      	  </div>
	    	    <div id="whats_happening_submit">
  		        <label class="invisible">Update</label>
	  	        <input type="submit" name="status_update" id="status_update" 
	  	               value="Update"/>
	    	    </div>
          </form> 
	      </div>
	      <div id="statuses"> {
	      if($filter)
	      then
	      for $status in twitter:get-filtered-timeline-for($username,$filter)/*:status
	      order by xs:integer($status/*:id) descending
	      return
	        <div id="status_{$status/*:id}" class="status">
	          <strong> {$status/*:user/*:screen_name/text()} </strong>: 
	          {$status/*:text//text()}
	        </div> 
	      else 
	      for $status in twitter:get-timeline-for($username)/*:status
	      order by xs:integer($status/*:id) descending
	      return
	        <div id="status_{$status/*:id}" class="status">
	          <strong> {$status/*:user/*:screen_name/text()} </strong>: 
	          {$status/*:text//text()}
	          { if($status/*:user/*:screen_name eq $username)
	            then
	          <div id="status_actions"> 
	            [ <a href="delete.xqy?username={$username}&amp;password={$password}&amp;id={$status/*:id}">delete</a> ] [ <a href="hide.xqy?username={$username}&amp;password={$password}&amp;id={$status/*:id}">hide</a> ]
	          </div>
	            else
	              ''
	          }
	        </div> 
	      }
	      </div>
	    </div> 
	    else
	    <div id="login_form">
	   	  <h1>Welcome to Twitter. Please sign in!</h1> {  
	   	      if(($username or $password) and not($auth_successful))
	   	      then
	   	  <div id="flash_error">
	   	    Authentication Failed. Please try again.
	   	  </div>
	   	      else
	   	        '' }
  		  <form method="post" action="default.xqy">
    		  <div id="login_input_username">
    		    <label>Username</label>
	    	    <input type="text" name="username" id="username" />
	    	  </div>
  	  	  <div id="login_input_password">
  		      <label>Password</label>
	  	      <input type="password" name="password" id="password" />
	    	  </div>
	    	  <div id="login_submit">
  		      <label class="invisible">Login to Twitter</label>
	  	      <input type="submit" name="login" id="login" value="Login to Twitter"/>
	    	  </div>
        </form> 
      </div> } 
		</div>
	</body>
</html>)
