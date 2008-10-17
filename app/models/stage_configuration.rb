class StageConfiguration < ConfigurationParameter
  belongs_to :stage
  
  validates_presence_of :stage
  validates_uniqueness_of :name, :scope => :stage_id

  after_save :write_capfile

  def write_capfile
    stage.write_capfile
  end

end
