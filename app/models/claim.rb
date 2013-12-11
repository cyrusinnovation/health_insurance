class Claim < ActiveRecord::Base
  belongs_to :oxford

  def mark_as_processed
    self.state = 'processed'
    save
  end
end
