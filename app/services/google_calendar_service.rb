class GoogleCalendarService
  CLIENT_ID = ENV["GOOGLE_CLIENT_ID"]
  CLIENT_SECRET = ENV["GOOGLE_CLIENT_SECRET"]
  def initialize(session)
    @session = session
  end

  def authorized_client
    client = Signet::OAuth2::Client.new(
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      token_credential_uri: "https://oauth2.googleapis.com/token",
      access_token: @session[:access_token],
      refresh_token: @session[:refresh_token]
    )
    begin
      if client.expired?
        client.refresh!
        @session[:access_token] = client.access_token
      end
    rescue Signet::AuthorizationError => e
      Rails.logger.error("Google OAuth refresh failed: #{e.message}")
      @session.delete(:access_token)
      return nil
    end
    client
  end


  def add_event_to_google_calendar(journal)
    return false unless @session[:access_token]
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorized_client

    event = Google::Apis::CalendarV3::Event.new(
      summary: journal.title,
      description: journal.content,
      start: Google::Apis::CalendarV3::EventDateTime.new(date: journal.date.to_s),
      end: Google::Apis::CalendarV3::EventDateTime.new(date: (journal.date+1).to_s)
    )
    created_event=service.insert_event(journal.calendar_id, event)
    journal.update(event_id: created_event.id)
  end

  def update_event_to_google_calendar(journal)
    return false unless @session[:access_token]
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorized_client

    begin
      event = service.get_event(journal.calendar_id, journal.event_id)
      event.summary = journal.title
      event.description = journal.content
      event.start= Google::Apis::CalendarV3::EventDateTime.new(date: journal.date.to_s)
      event.end= Google::Apis::CalendarV3::EventDateTime.new(date: (journal.date+1).to_s)
      service.update_event(journal.calendar_id, event.id, event)
    rescue Google::Apis::ClientError
      false
    end
  end

  def delete_event_to_google_calendar(journal)
    return false unless @session[:access_token]
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = authorized_client
    begin
      event = service.get_event(journal.calendar_id, journal.event_id)

      service.delete_event(journal.calendar_id, event.id)
    rescue Google::Apis::ClientError
      false
    end
  end
end
