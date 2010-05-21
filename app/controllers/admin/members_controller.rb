class Admin::MembersController < Admin::ApplicationController
  before_filter :find_member, :except => :new
  before_filter :find_project, :only => :new
	TMPLATE = 'admin/projects/settings/members'
  def new
    @project.members << Member.new(params[:member]) if request.post?
    respond_to do |format|
      format.html { redirect_to :action => 'settings', :tab => 'members', :id => @project }
      format.js { render(:update) {|page| page.replace_html "tab-content-members", :partial => TMPLATE} }
    end
  end
  
  def edit
    if request.post? and @member.update_attributes(params[:member])
  	 respond_to do |format|
        format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'members', :id => @project }
        format.js { render(:update) {|page| page.replace_html "tab-content-members", :partial => TMPLATE} }
      end
    end
  end

  def destroy
    @member.destroy
	respond_to do |format|
      format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'members', :id => @project }
      format.js { render(:update) {|page| page.replace_html "tab-content-members", :partial => TMPLATE} }
    end
  end

private
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_member
    @member = Member.find(params[:id]) 
    @project = @member.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
