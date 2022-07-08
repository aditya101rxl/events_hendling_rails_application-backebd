class Api::EventsController < Api::BaseController
	skip_before_action :authorize_request, except: [:register, :unregister]
	
	def tags
		all_tags = Tag.select(:name)
  	render json: all_tags
	end

	def event
		event_id = params[:id]
    @event = Event.find(event_id)
    render json: @event
	end

	def events
		event_type = params[:event_type]
    sign = "<="
    tag_list = params[:tag_list].strip.split(',')

    if tag_list.size == 0
      tag_list = Tag.select(:name)
    end

    if params[:sub_event_type]=="upcoming"
      sign = ">="
    end

    if event_type == "all_events"
      @events = Event.where("registration_end #{sign} ?", Time.now)
                     .joins(taggables: :tag)
                     .where(tag: {name: tag_list})
      render json: @events

    else
      @events = Event.where("event_type = ? AND registration_end #{sign} ?", event_type, Time.now)
                     .joins(taggables: :tag)
                     .where(tag: {name: tag_list})
      render json: @events
    end
	end

	def register
		@relation = Registerable.new(
      :user_id => params[:user_id],
      :event_id => params[:event_id]
      );
    if @relation.save
      render json: {data: @relation, msg: "registeration successful"};
    else
      render json: {error: 'failed', msg: "registeration failed"};
    end
	end

  def unregister
    @relation = Registerable.destroy(params[:id])
    render json: {data: @relation, msg: "unregisteration successful"}
  end
end