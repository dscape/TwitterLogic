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
	  let $filter            := xdmp:get-request-field("filter")
	  let $friends_timeline  := twitter:store-timeline($username,$password)
    let $auth_successful   := twitter:auth-successful($username,$password)
	  return
	    if ($auth_successful)
	    then
	    <div id="statuses_container">
	      <h1>Welcome to Twitter - { $username } </h1>
	      <div id="filter">
	        <form>
      		  <div id="filter_status">
    	  	    <label>Filter by user</label>
	    	      <input type="text" name="screen_name" id="screen_name" />
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
	    	      <input type="text" name="new_status" id="new_status" />
	      	  </div>
	    	    <div id="whats_happening_submit">
  		        <label class="invisible">Update</label>
	  	        <input type="submit" name="status_update" id="status_update" 
	  	               value="Update"/>
	    	    </div>
          </form> 
	      </div>
	      <div id="statuses"> {
	      for $status in twitter:get-timeline-for($username)/*:status
	      order by xs:integer($status/*:id) descending
	      return
	        <div id="status_{$status/*:id}" class="status">
	          <strong> {$status/*:user/*:screen_name/text()} </strong>: 
	          {$status/*:text//text()}
	          { if($status/*:user/*:screen_name eq $username)
	            then
	          <div id="status_actions"> [ <a href="#">delete</a> ] </div>
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
	   	      if($username and not($auth_successful))
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
