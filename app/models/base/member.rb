class Member < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :project

  validates_presence_of :role, :user, :project
  validates_uniqueness_of :user_id, :scope => [:project_id, :role_id]

  def validate
    errors.add :role_id, :activerecord_error_invalid if role && !role.member?
  end
  
  def name
    self.user.name
  end
  
  def <=>(member)
    role == member.role ? (user <=> member.user) : (role <=> member.role)
  end
  
end
