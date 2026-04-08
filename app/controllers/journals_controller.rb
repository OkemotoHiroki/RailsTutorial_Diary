class JournalsController < ApplicationController
  def index
    @journals = Journal.all.order(date: :asc)
  end

  def show
    @journal = Journal.find(params[:id])
  end

  def new
    @journal = Journal.new(date: params[:date])
  end

  def edit
    @journal = Journal.find(params[:id])
  end

  def create
    @journal = Journal.new(journal_params)
    @journal.calendar_id ||= "primary"
    if @journal.save
      if add_event_to_google_calendar(@journal)
        flash[:notice] ="Googleカレンダーの同期に成功しました。"
      else
        flash[:alert] = "Googleカレンダーの同期に失敗しました。"
      end
      redirect_to @journal
    else
      flash[:alert] = "日記の新規作成に失敗しました。"
      render :new
    end
  end

  def update
    @journal = Journal.find(params[:id])
    if @journal.update(journal_params)
      if @journal.event_id
        if update_event_to_google_calendar(@journal)
          flash[:notice] = "Googleカレンダーの同期に成功しました。"
        else
          flash[:alert] = "Googleカレンダーの同期に失敗しました。"
        end
      end
        redirect_to @journal
    else
      render :edit
    end
  end

  def destroy
    @journal = Journal.find(params[:id])
    if @journal.event_id
      delete_event_to_google_calendar(@journal)
    end
    @journal.destroy
    redirect_to journals_path
  end

  def journal_params
    params.require(:journal).permit(:date, :title, :content)
  end

  def add_event_to_google_calendar(journal)
    return false unless session[:access_token]
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = session[:access_token]

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
    return false unless session[:access_token]
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = session[:access_token]

    event = service.get_event(journal.calendar_id, journal.event_id)
    event.summary = journal.title
    event.description = journal.content
    event.start= Google::Apis::CalendarV3::EventDateTime.new(date: journal.date.to_s)
    event.end= Google::Apis::CalendarV3::EventDateTime.new(date: (journal.date+1).to_s)
    updated_event = service.update_event(journal.calendar_id, event.id, event)
  end

  def delete_event_to_google_calendar(journal)
    return false unless session[:access_token]
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = session[:access_token]

    event = service.get_event(journal.calendar_id, journal.event_id)
    service.delete_event(journal.calendar_id, event.id)
  end
end
