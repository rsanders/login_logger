class LoginLog < ActiveRecord::Base
  belongs_to :user
  
  named_scope :by_date, lambda { |*args| 
     {
     :conditions => ["created_at BETWEEN ? AND ?", (args[0]||Time.now).beginning_of_day.to_s(:db), (args[1]||Time.now).end_of_day.to_s(:db)] 
     } } 
     
     
  named_scope :last_ten_minutes, lambda { |*args| 
     {
     :conditions => ["created_at BETWEEN ? AND ?", 10.minutes.ago.to_s(:db), Time.now.to_s(:db)] 
     } } 
 
  named_scope :failed, :conditions => ['failed = ?', true]

  # include Equid::CommonScopes

  named_scope :for_user, lambda {|user|
    return {} if user.blank?
    idlike = case user
      when User then user.id
      else user.to_s
    end
    { :joins => ["left outer join users on #{self.table_name}.user_id = users.id"],
      :conditions => ["#{self.table_name}.user_id = ? OR #{self.table_name}.login = ? OR users.login = ?",
                      idlike, idlike, idlike] }
  }

  acts_as_scoped_search
  searchable_on do
    scope :text_search
    fields :login, :created_at, :ip_address
  end


end