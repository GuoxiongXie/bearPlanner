class ApplicationController < ActionController::Base
  protect_from_forgery

  def invite_id_matches_user
    curUID = session[:uid]
    invObj = Invite.find_by_id(params[:invite_id])
    inviteeID = invObj.users_id
    if inviteeID == curUID
      return true
    else
      redirect_to :action => "show_invites", :notice => "You can not access that invite."
      return false 
    end
  end

  def cal_id_matches_user
    curUID = session[:uid]
    calObj = Calendar.find_by_id(params[:cal_id])
    uID = calObj.users_id
    if uID == curUID
      return true
    else
      redirect_to :action => "show_calendars", :notice => "You can not access that item."
      return false   
    end
  end

  def login_required
    if session[:uid] #if there is a logged in user
      return true
    end #Otherwise redirect to login page
    redirect_to :controller => "bear_planner", :action=> "login", :notice=>"Please log in to view this page"
    return false 
  end
end
