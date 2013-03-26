class Reference < ActiveRecord::Base
  belongs_to :location
  belongs_to :tag
  has_many :user_references, :dependent => :destroy
  has_many :users, :through => :user_references

  before_create :initialize_time_block

  #
  # initialize_time_block
  #
  def initialize_time_block
    self.time_block = Reference.time_to_time_block(Time.now)
  end

  #
  # time_to_time_block
  #
  def self.time_to_time_block(time)
      @utc_time = time.utc;
      Time.utc(@utc_time.year,
               @utc_time.month,
               @utc_time.day,
               @utc_time.hour,
               @utc_time.min.div(10)*10);
  end

  #
  # increment_time_block
  #
  def self.increment_time_block(time_block, num_steps)
    @step_size = 600;  # 10 minutes
    time_block + @step_size * num_steps;
  end

  #
  # decrement_time_block
  #
  def self.decrement_time_block(time_block, num_steps)
    @step_size = 600;  # 10 minutes
    time_block - @step_size * num_steps;
  end

end
