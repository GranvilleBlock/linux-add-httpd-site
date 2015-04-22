SET @oldsite='http://oldsite.local';
SET @newsite='http://newsite.ru';
UPDATE wp_options SET option_value = REPLACE(option_value, 
@oldsite, @newsite) WHERE option_name = 
'home' OR option_name = 'siteurl';
UPDATE wp_posts SET guid = REPLACE(guid, 
@oldsite,@newsite);
UPDATE wp_posts SET post_content = REPLACE(post_content, 
@oldsite, @newsite);
