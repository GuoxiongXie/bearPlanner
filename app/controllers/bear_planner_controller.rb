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
    userID = session[:uid]
    targetUser = Users.find_by_id(userID)
    calList = targetUser.calendars
    
    @calendars = {}
    calList.each do |cal|
      @calendars[cal.name] = cal.id
    end
    #Attempts to create a new event
    calID = params[:cal_id]
    targetCal = Calendar.find_by_id(calID)

    
    targetUser = Users.find_by_id(userID)
    calList = targetUser.calendars
    
    @calendars = {}
    calList.each do |cal|
      @calendars[cal.name] = cal.id
    end  
    
    tarEvent = Event.find_by_id(params[:event_id])
    @eventName = tarEvent.name
    @eventId = tarEvent.id
    @eventStarts = tarEvent.start
    @eventEnds = tarEvent.end
    @eventOwner = tarEvent.users_id #DEBUG: can call id?? users_id as ownerID
    #check if I'm the owner of event
    if userID == @eventOwner
      @invitees = []
      inviteList = tarEvent.invites #list of inviteObj
      inviteList.each do |inviteObj|
        tarUserID = inviteObj.users_id
        tarUserObj = Users.find_by_id(tarUserID)
        userName = tarUserObj.name
        @invitees << {'name' => userName}
      end
    end
    
    if userID != @eventOwner #latest change!!
      if params[:notice] == nil
        ownerName = Users.find_by_id(tarEvent.users_id).name
        redirect_to :action => "edit_event", :notice => "You can not edit this event, contact owner:#{ownerName}", :cal_id => calID, :event_id => params[:event_id]       
      end

    else
      if request.post? #checks if the user clicked the "submit" button on the form
        #tarCal = Calendar.find_by_id(params[:old_cal_id])
        
        calID = params[:cal_id]
        tarEvent = Event.find_by_id(params[:event_id])
        tarEvent.calendar_id = params[:cal_id]
        tarEvent.name = params[:eventName]
        tarEvent.start = params[:starts_at]
        tarEvent.end = params[:ends_at]
        tarEvent.users_id = session[:uid]
        
        inviteesStr = params[:invitees]
        invitees = []
        if inviteesStr != nil
          invitees = inviteesStr.split(",") #invitees is a list of names
        end  
        listOfNotValidInvitees = ""
        
        if tarEvent.save #if they have submitted the form attempts to save the event
          #update old invitees
          oldInviteeList = tarEvent.invites
          oldInviteeList.each do |oldInvitee|
            if oldInvitee.users_id != session[:uid]
              eventID = oldInvitee.event_id
              eventObject = Event.find_by_inviteID(oldInvitee.id)
              if eventObject != nil
                eventObject.name = params[:eventName]
                eventObject.start = params[:starts_at]
                eventObject.end = params[:ends_at]
                eventObject.save!
              end
            end
            oldInvitee.msg = params[:inviteMessage]
            oldInvitee.save!
          end
          
          #new invitees        
          invitees.each do |name|
            invitee = Invite.new do |i|
              i.event_id = tarEvent.id
              userObj = Users.find_by_name(name)
              if userObj == nil
                i.users_id = nil
              else
                i.users_id = userObj.id  
              end
              
              i.msg = params[:inviteMessage]
              i.accept = false  # false meaning the invite is currently pending
            end
            if invitee.save # if the adding invitee has already exist in the invite table
              tarEvent.invites << invitee
            else #not valid  
              listOfNotValidInvitees << name << " "
             
            end        
          end
          listOfNotValidInvitees = listOfNotValidInvitees[0...(listOfNotValidInvitees.length-1)]
          
          #targetCal.events << event
          tarEvent.save!
          
          #targetUser.save!
          
          if listOfNotValidInvitees.length > 0
            redirect_to :action => "show_calendar", :cal_id => calID, :notice => "The following invited usernames are invalid/duplicates and invites were not sent:#{listOfNotValidInvitees}"
          else
            redirect_to :action => "show_calendar", :cal_id => calID
          end
        else# This will happen if one of the validations define in /app/models/event.rb fail for this instance.
          redirect_to :action => "edit_event", :notice => "An error has occurred.", :event_id => params[:event_id], :cal_id => calID
        end
      end
    end
  end

  def create_calendar
    #I added the following
    userID = session[:uid]
    targetUser = Users.find_by_id(userID)
    #end of my addition
    newCal = Calendar.new do |cal|
      cal.name = params[:calName]
      cal.description = params[:calDescription]
      cal.users_id = userID
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
    calID = params[:cal_id]
    userID = session[:uid]
    targetUser = Users.find_by_id(userID)
    @calName = targetUser.calendars.find_by_id(calID).name
    @calDescription = targetUser.calendars.find_by_id(calID).description
        
    if request.post?
      newName = params[:calName]
      newDes = params[:calDescription]
      targetCal = targetUser.calendars.find_by_id(calID)
      targetCal.name = newName
      targetCal.description = newDes
      #@calName = target
      
      if targetCal.save
        targetUser.save!      
        redirect_to :action => "show_calendar",:cal_id => calID
      else
        redirect_to :action => "edit_calendar", :cal_id => calID, :notice => "An error has occurred."  
      end  
    end  
  end

  def delete_calendar
    calID = params[:cal_id]
    #targetCal = Calendar.find_by_id(calID)
    #userID = session[:uid]
    #targetUser = Users.find_by_id(userID)
    #calObj = 
    targetCal = Calendar.find_by_id(calID)
    eventList = targetCal.events
    if eventList.length == 0
      Calendar.destroy(calID)
      redirect_to :action => "show_calendars"
    else
      redirect_to :action => "show_calendar", :notice => "You can not delete a calendar that contains any events.", :cal_id => calID
    end    
    #if 
    #  targetCal = targetUser.calendars.find_by_id(calID)
      
    #end
  end

  def create_event #copy from sign_up
    #Attempts to create a new event
    calID = params[:cal_id]
    targetCal = Calendar.find_by_id(calID)
    inviteesStr = params[:invitees]
    invitees = []
    if inviteesStr != nil
      invitees = inviteesStr.split(",") #invitees is a list of names
    end  
    listOfNotValidInvitees = ""
    
    userID = session[:uid]
    targetUser = Users.find_by_id(userID)
    calList = targetUser.calendars
    
    @calendars = {}
    calList.each do |cal|
      @calendars[cal.name] = cal.id
    end  
    
    if request.post? #checks if the user clicked the "submit" button on the form
      event = Event.new do |e|  #DEBUG: Event.new or Events.new?? 
        e.name = params[:eventName]
        e.start = params[:starts_at]
        e.end = params[:ends_at]
        e.calendar_id = calID
        e.users_id = session[:uid]
      end #creates a new instance of the user model
      if event.save #if they have submitted the form attempts to save the event        
        invitee = Invite.new do |i| #adding the creater of the event to the invite table
          i.event_id = event.id
          i.users_id = session[:uid]
          i.msg = params[:inviteMessage]
          i.accept = true
        end

        event.invites << invitee
 
        invitees.each do |name|
          invitee = Invite.new do |i|
            i.event_id = event.id
            userObj = Users.find_by_name(name)
            if userObj == nil
              i.users_id = nil
            else
              i.users_id = userObj.id  
            end
            
            i.msg = params[:inviteMessage]
            i.accept = false  # false meaning the invite is currently pending
          end
          if invitee.save # if the adding invitee has already exist in the invite table
            event.invites << invitee
          else #not valid  
            listOfNotValidInvitees << name << " "
           
          end        
        end
        listOfNotValidInvitees = listOfNotValidInvitees[0...(listOfNotValidInvitees.length-1)]
        
        targetCal.events << event
        targetCal.save!
        
        targetUser.save!
        
        if listOfNotValidInvitees.length > 0
          redirect_to :action => "show_calendar", :cal_id => calID, :notice => "The following invited usernames are invalid/duplicates and invites were not sent:#{listOfNotValidInvitees}"
        else
          redirect_to :action => "show_calendar", :cal_id => calID
        end
      else# This will happen if one of the validations define in /app/models/event.rb fail for this instance.
        redirect_to :action => "create_event", :notice => "An error has occurred.", :cal_id => calID
      end
    end
       
  end


  def delete_event
    userID = session[:uid]
    eventObj = Event.find_by_id(params[:event_id])
    ownerID = eventObj.users_id
    if userID == ownerID #the deleter is the owner
      eventID = params[:event_id]
      tarInList = Invite.find_all_by_event_id(eventID) #find all the invite with the original eventID
      Event.delete(params[:event_id])
      tarInList.each do |inv|
        tarInID = inv.id #inviteID
        if inv.accept == true
          tarEventList = Event.find_all_by_inviteID(tarInID)
          tarEventList.each do |e|
            eid = e.id
            Event.delete(eid) #remove entries in Event table
            #Event.save!
          end  
        end
        Invite.delete(tarInID)
        #Invite.save!  
      end  
    else #not owner deleting
      inID = eventObj.inviteID
      Event.delete(params[:event_id])      
      Invite.delete(inID)   
      #Event.save!
      #Invite.save!
    end
    redirect_to :action => "show_calendar", :cal_id => params[:cal_id]
  end

  def show_invites
    userID = session[:uid]
    #targetUser = Users.find_by_id(userID)
    tarInviteList = Invite.find_all_by_users_id(userID)
    @allInvitees = []
    tarInviteList.each do |anIn|
      if anIn.accept == false #pending
        eventObj = Event.find_by_id(anIn.event_id)
        eventName = eventObj.name
        @allInvitees << {'inviteId' => anIn.id, 'eventName' => eventName}
      end
    end
  end

  def show_invite
    inviteID = params[:invite_id]
    inObj = Invite.find_by_id(inviteID)
    eventObj = Event.find_by_id(inObj.event_id)
    
    @inviteMessage = inObj.msg
    @inviteId = inObj.id
    @eventName = eventObj.name
    @eventStarts = eventObj.start
    @eventEnds = eventObj.end
    @eventUserName = Users.find_by_id(eventObj.users_id).name
    userID = session[:uid]
    targetUser = Users.find_by_id(userID)
    calList = targetUser.calendars
    
    @calendars = {}
    calList.each do |cal|
      @calendars[cal.name] = cal.id
    end
    
    if request.post?
      if params[:commit] == "Accept"
        newEvent = Event.new do |e|
          e.name = @eventName
          e.start = @eventStarts
          e.end = @eventEnds
          e.calendar_id = params[:cal_id]
          e.users_id = eventObj.users_id
          e.inviteID = inviteID
        end
        
        if newEvent.save
          inObj.accept = true
          inObj.save!
          #if inObj.save
            redirect_to :action => "show_invites"
          #else
            #redirect_to :action => "show_invite", :notice => "An error has occurred.", :invite_id => inviteID 
          #end
        else
          redirect_to :action => "show_invite", :notice => "An error has occurred.", :invite_id => inviteID  
        end    
      else #decline
         Invite.destroy(inviteID)
         redirect_to :action => "show_invites" 
      end
    end    
  end
end