require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :deployments, :dependent => :nullify, :order => 'created_at DESC'
  has_many :scheduled_deployments

  has_and_belongs_to_many :stages
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  
  attr_accessible :login, :email, :password, :password_confirmation, :time_zone, :tz

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
    
  def validate_on_update
    if User.find(self.id).admin? && !self.admin?
      errors.add('admin', 'status can no be revoked as there needs to be one admin left.') if User.admin_count == 1
    end
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  # These two methods allow controller before_filters to decide
  # whether we should let the user see/use a given project/stage
  def auth_project(project)
    authorize(project, ".project")
  end
 
  def auth_stage(stage)
    authorize(stage)
  end
  
  def remember_token?
    remember_token_expires_at && Time.now < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def admin?
    self.admin.to_i == 1
  end
  
  def revoke_admin!
    self.admin = 0
    self.save!
  end
  
  def make_admin!
    self.admin = 1
    self.save!
  end
  
  def self.admin_count
    count(:id, :conditions => ['admin = 1'])
  end
  
  def recent_deployments(limit=3)
    self.deployments.find(:all, :limit => limit, :order => 'created_at DESC')
  end

  # I should figure out the vernacular way of doing this.
  def update_attributes(args = self.attributes)
    if args[:stages] then
      stages.delete_all
      args[:stages].each { |s| stages << Stage.find(s.to_i) }
    else
      self.stages.delete_all
    end
    super(args)
  end
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    def authorize(obj, method = nil)
      return true if admin?
      rvalue = false
      stages.each do |stg|
        rvalue = true if eval( %{stg#{method} == obj })
      end
      rvalue
    end
end
