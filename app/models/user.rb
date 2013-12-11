class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :myrsc
  has_many :oxfords
  accepts_nested_attributes_for :myrsc, :oxfords, :reject_if => lambda { |a| a[:username].blank? }, :allow_destroy => true

end