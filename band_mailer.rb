require 'mail'

HEADERS = ["Band", "Date", "Purchase Tickets Here!"]
INTERVAL = "168 hours"
RECIPIENTS = ["adrian.zarifis@crowdflower.com","wil@crowdflower.com","kirsten.gokay@crowdflower.com","christina.chiu@crowdflower.com"]

#configure options for mail gem
mail_options = {
	:address => "smtp.gmail.com",
	:port => 587,
	:domain => "gmail.com",
	:user_name => "ribbymailer@gmail.com",
	:password => "123dolores",
	:authentication => 'plain',
	:enable_starttls_auto => true
}

Mail.defaults do
	delivery_method :smtp, mail_options
end

def send_email(body)
	Mail.deliver do
		from 'ribbymailer@gmail.com'
		to RECIPIENTS
		subject "Your Favorite Bands Are Here!" 
		content_type 'text/html; charset=UTF-8'
		body File.read('body.txt')
	end
end
