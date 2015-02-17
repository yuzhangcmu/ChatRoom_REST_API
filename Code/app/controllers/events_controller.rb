  require 'time'

  class EventsController < ApplicationController
    before_action :set_event, only: [:show, :edit, :update, :destroy]
    skip_before_filter  :verify_authenticity_token

    # GET /events
    # GET /events.json

    # 1. Event Details
    #   GET /events?from=DATE&to=DATE
    def index
      if params[:from] != nil
        @events = Event.where("event_date >= :start_date AND event_date <= :end_date",
          {start_date: params[:from].to_datetime, end_date: params[:to].to_datetime})
      else
        @events = Event.all
      end      
      
      render json: @events, :only => [:event_date, :user, :event_type, :otheruser, :message]
    end

    # 2. Event Summary
    #   GET /summary?from=DATE&to=DATE&by=TIMEFRAME
    def summary
      if params[:from] != nil && params[:to] != nil && params[:by] != nil

        start_time = nil
        end_time = nil
        if params[:by] == 'day'
          group_hash = Event.select('STRFTIME("%Y-%m-%d", event_date) AS date, COUNT(*) AS total')
          .where("event_date >= :start_date AND event_date <= :end_date",
            {start_date: params[:from].to_datetime, end_date: params[:to].to_datetime}).group('date')  

          group_hash_enter = Event.select('STRFTIME("%Y-%m-%d", event_date) AS date, COUNT(*) AS enters')
          .where("event_date >= :start_date AND event_date <= :end_date AND event_type == 'enter'",
            {start_date: params[:from].to_datetime, end_date: params[:to].to_datetime}).group('date')           
          group_hash_leave = Event.select('STRFTIME("%Y-%m-%d", event_date) AS date, COUNT(*) AS leaves')
          .where(event_type: "leave").group('date')
          group_hash_comment = Event.select('STRFTIME("%Y-%m-%d", event_date) AS date, COUNT(*) AS comments')
          .where(event_type: "comment").group('date')
          group_hash_highfive = Event.select('STRFTIME("%Y-%m-%d", event_date) AS date, COUNT(*) AS highfives')
          .where(event_type: "highfive").group('date')    

        elsif params[:by] == 'hour'
          group_hash = Event.select('STRFTIME("%Y-%m-%d %H", event_date) AS date, COUNT(*) AS total')
          .where("event_date >= :start_date AND event_date <= :end_date",
            {start_date: params[:from].to_datetime, end_date: params[:to].to_datetime}).group('date')  

          group_hash_enter = Event.select('STRFTIME("%Y-%m-%d %H", event_date) AS date, COUNT(*) AS enters')
          .where("event_date >= :start_date AND event_date <= :end_date AND event_type == 'enter'",
            {start_date: params[:from].to_datetime, end_date: params[:to].to_datetime}).group('date')           
          group_hash_leave = Event.select('STRFTIME("%Y-%m-%d %H", event_date) AS date, COUNT(*) AS leaves')
          .where(event_type: "leave").group('date')
          group_hash_comment = Event.select('STRFTIME("%Y-%m-%d %H", event_date) AS date, COUNT(*) AS comments')
          .where(event_type: "comment").group('date')
          group_hash_highfive = Event.select('STRFTIME("%Y-%m-%d %H", event_date) AS date, COUNT(*) AS highfives')
          .where(event_type: "highfive").group('date')              

        elsif params[:by] == 'minute'
          group_hash = Event.select('STRFTIME("%Y-%m-%d %H:%M", event_date) AS date, COUNT(*) AS total')
          .where("event_date >= :start_date AND event_date <= :end_date",
            {start_date: params[:from].to_datetime, end_date: params[:to].to_datetime}).group('date')  

          group_hash_enter = Event.select('STRFTIME("%Y-%m-%d %H:%M", event_date) AS date, COUNT(*) AS enters')
          .where("event_date >= :start_date AND event_date <= :end_date AND event_type == 'enter'",
            {start_date: params[:from].to_datetime, end_date: params[:to].to_datetime}).group('date')           
          group_hash_leave = Event.select('STRFTIME("%Y-%m-%d %H:%M", event_date) AS date, COUNT(*) AS leaves')
          .where(event_type: "leave").group('date')
          group_hash_comment = Event.select('STRFTIME("%Y-%m-%d %H:%M", event_date) AS date, COUNT(*) AS comments')
          .where(event_type: "comment").group('date')
          group_hash_highfive = Event.select('STRFTIME("%Y-%m-%d %H:%M", event_date) AS date, COUNT(*) AS highfives')
          .where(event_type: "highfive").group('date')                    
        end
      else
        @events = Event.all
      end 

      # create an array to store the result.
      response_summary = Array.new(group_hash.length) {Hash.new}

      # Merge all the summary together.
      response_summary.each_with_index do |x, index|
        puts index
        response_summary[index]["date"] = DateTime.parse(group_hash[index][:date]).iso8601
        response_summary[index]["enters"] = 0
        response_summary[index]["leaves"] = 0
        response_summary[index]["comments"] = 0
        response_summary[index]["highfives"] = 0
        puts response_summary

        group_hash_enter.each do |x2| 
          if x2[:date] == group_hash[index][:date]
            response_summary[index]["enters"] = x2[:enters]
          end
        end

        group_hash_leave.each do |x2| 
          if x2[:date] == group_hash[index][:date]
            response_summary[index]["leaves"] = x2[:leaves]
          end
        end

        group_hash_comment.each do |x2| 
          if x2[:date] == group_hash[index][:date]
            response_summary[index]["comments"] = x2[:comments]
          end
        end

        group_hash_highfive.each do |x2| 
          if x2[:date] == group_hash[index][:date]
            response_summary[index]["highfives"] = x2[:highfives]
          end
        end
      end                  

      render :json => response_summary.to_json
    end

    # GET /events/1
    # GET /events/1.json
    def show
    end

    # GET /events/new
    def new
      @event = Event.new
    end

    # GET /events/1/edit
    def edit
    end

    # POST /events
    # POST /events.json

    # 3. Submit Event 
    #   POST /event
    #   Content­Type: application/json
    def create
      @event = Event.new(event_params)

      respond_to do |format|
        if @event.save
          #format.html { redirect_to @event, notice: 'Event was successfully created.' }
          #format.json { render action: 'show', status: :ok, location: @event }

          response_create_ok = {"status" => "ok"}
          format.json { render status: :ok, json: response_create_ok}
          
        else
          format.html { render action: 'new' }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /events/1
    # PATCH/PUT /events/1.json
    def update
      respond_to do |format|
        if @event.update(event_params)
          format.html { redirect_to @event, notice: 'Event was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /events/1
    # DELETE /events/1.json
    def destroy
      @event.destroy
      respond_to do |format|
        format.html { redirect_to events_url }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event
        @event = Event.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def event_params
        params.require(:event).permit(:event_date, :user, :event_type, :otheruser, :message)
      end
    end
