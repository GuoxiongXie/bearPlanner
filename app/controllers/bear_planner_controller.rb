class BearPlannerController < ApplicationController
  #The next three lines require that some method in "application_controller.rb" 
  # be run before certain methods start
  before_filter :login_required, :except => [:signup, :home, :login]
  before_filter :cal_id_matches_user, :except =>[:create_calendar, :signup, :home, :login, :logout, :show_calendars, :show_invites, :show_invite]
  before_filter :invite_id_matches_user, :only=>[:show_invite]
  
  def home
  end

  def signup
    #Attempts to create a new user
    user = Users.new do |u| 
      u.name = params[:username]
      u.password = params[:password]
    end #creates a new instance of the user model
    if request.post? #checks if the user clicked the "submit" button on the form
      if user.save #if they have submitted the form attempts to save the user
        session[:uid] = user.id #Logs in the new user automatically
        redirect_to :action => "show_calendars" #Goes to their new calendars page
      else #This will happen if one of the validations define in /app/models/user.rb fail for this instance.
        redirect_to :action => "signup", :notice=>"An error has occurred." #Ask them to sign up again
      end
    end
  end

  def login
    if request.post? #If the form was submitted
      user = Users.find(:first, :conditions=>['name=?',(params[:username])]) #Find the user based on the name submitted
      if !user.nil? && user.password==params[:password] #Check that this user exists and it's password matches the inputted password
        session[:uid] = user.id #If so log in the user
        redirect_to :action => "show_calendars" #And redirect to their calendars
      else
        redirect_to :action => "login", :notice=> "Invalid username or password. Please try again." #Otherwise ask them to try again. 
      end
    end
  end

  def logout
    session[:uid] = nil #Logs out the user
    redirect_to :action => "home" #redirect to the homepage
  end

  def show_calendars    
    userID = session[:uid] 
    targetUser = Users.find_by_id(userID)
    targetCalendars = targetUser.calendars #returns a list of calendar objects
    
    @calendarArray = []
    targetCalendars.each do |cal|
      @calendarArray << {'id' => cal.id, 'name' => cal.name, 'description' => cal.description} #DEBUG: cal.id???
    end
    #end #remove this
  end

  def show_calendar
    calID = params[:cal_id]
    targetCal = Calendar.find_by_id(calID)
    @calName = targetCal.name
    @calDescription = targetCal.description
    
    @eventArray = []
    targetEvents = targetCal.events #return a list of events objects
    targetEvents.each do |anEvent|
      @eventArray << {'id' => anEvent.id, 'name' => anEvent.name, 'starts_at' => anEvent.start, 'ends_at' => anEvent.end} #DEBUG: cal.id???
    end
  end

  def edit_event #copy from login
    
  end

  def create_calendar
    #I added the following
    userID = session[:uid]
    targetUser = Users.find_by_id(userID)
    #end of my addition
    newCal = Calendar.new do |cal|
      cal.name = params[:calName]
      cal.description = params[:calDescription]
    end  
    if request.post?
      if newCal.save # I also change this
        targetUser.calendars << newCal #add to user's calendarList
        targetUser.save! #save in user
        redirect_to :action => "show_calendar", :cal_id => newCal.id # redirect to their calendars
      else
        redirect_to :action => "create_calendar",:notice => "An error has occurred."
      end
    end  
  end

  def edit_calendar
  end

  def delete_calendar
  end

  def create_event #copy from sign_up
    #Attempts to create a new event
    calID = params[:cal_id]
    event = Event.new do |e|  #DEBUG: Event.new or Events.new?? 
      e.name = params[:username]
      e.password = params[:password]
    end #creates a new instance of the user model
    if request.post? #checks if the user clicked the "submit" button on the form
      if user.save! #if they have submitted the form attempts to save the user
        session[:uid] = user.id #Logs in the new user automatically
        redirect_to :action => "show_calendars" #Goes to their new calendars page
      else #This will happen if one of the validations define in /app/models/user.rb fail for this instance.
        redirect_to :action => "signup", :notice=>"An error has occurred." #Ask them to sign up again
      end
    end
    
  end


  def delete_event
  end

  def show_invites
  end

  def show_invite
  end

end
