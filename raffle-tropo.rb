require 'rest-client'

if $token.nil?
  # incoming text
  name = $currentCall.initialText
  if $currentCall.network == 'SMS' then
    log "Gettting http://lsrc.iriscouch.com/raffle2011/" + $currentCall.callerID
    response = RestClient.get("http://lsrc.iriscouch.com/raffle2011/" + $currentCall.callerID){ |response, request, result, &block|
      case response.code
        when 200
          say "Sorry, only one entry per person."
        when 404
          say "Thanks for entering the LSRC giveaway. SMS entry sponsored by Tropo. Build your own SMS and Voice apps for free at Tropo.com"
          response = RestClient.put 'http://lsrc.iriscouch.com/raffle2011/' + $currentCall.callerID, "{\"name\": \"#{name}\"}", {:content_type => :json}
        else
          say "Something went wrong"
      end
    }
  else
    say "Sorry, only SMS entries are allowed.", {:voice => 'vanessa'}
  end
else
  # outgoing message
  call $to, {:network => 'SMS'}
  say "Congratulations #{$name}! You are a winner at LSRC! Come down to the stage and grab your prize."
end
