class JournalsController < ApplicationController
  def index
    @journals = Journal.all.order(date: :asc)
  end

  def show
    @journal = Journal.find(params[:id])
  end

  def new
    @journal = Journal.new(date: params[:date])
    @journal.date ||= Date.today
  end

  def edit
    @journal = Journal.find(params[:id])
  end

  def create
    @journal = Journal.new(journal_params)
    @journal.calendar_id ||= "primary"
    if @journal.save
      calendar = GoogleCalendarService.new(session)
      if calendar.add_event_to_google_calendar(@journal)
        flash[:notice] ="Googleカレンダーの同期に成功しました。"
      else
        flash[:alert] = "Googleカレンダーの同期に失敗しました。"
      end
      redirect_to @journal
    else
      # flash[:alert] = "日記の新規作成に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @journal = Journal.find(params[:id])
    if @journal.update(journal_params)
      if @journal.event_id
        calendar = GoogleCalendarService.new(session)
        if calendar.update_event_to_google_calendar(@journal)
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
      calendar = GoogleCalendarService.new(session)
       if calendar.delete_event_to_google_calendar(@journal)
         flash[:notice] = "Googleカレンダーの日記を削除しました。"
       else
        flash[:alert] = "削除した日記はGoogleカレンダーに存在しませんでした。"
       end
    end
    @journal.destroy
    redirect_to journals_path
  end

  def journal_params
    params.require(:journal).permit(:date, :title, :content)
  end
end
