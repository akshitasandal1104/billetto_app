class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:vote]

  def index
    @events = Event.all.includes(:event_vote_count)
  end
  
  def vote
    command = Events::Commands::VoteOnEvent.new(
      event_id: params[:id],
      user_id: current_user.id,
      vote_type: params[:vote_type]
    )

    command.call

    redirect_to events_path, notice: "Vote recorded!"
  end
end