require 'spec_helper'

describe RubyCAS::Server::Core::CredentialRequester do

  # new login
    # generate login ticket
    # persist login ticket
    # send user_not_logged_in(ticket_string)

  # already logged in
    # if session is good
      # update last_used on session
      # send user_logged_in(target_service)
    # if session is invalid
      # ensure session is destroyed
      # generate/persist new login ticket
      # send user_not_logged_in(ticket_string)

  # gateway param
  # forced renew param
end
