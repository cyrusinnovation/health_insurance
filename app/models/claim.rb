class Claim < ActiveRecord::Base
  belongs_to :oxford

  def mark_as_processed
    self.state = 'processed'
    save
  end

  def claimant
    oxford.claimant
  end

  def relationship
    oxford.relationship
  end
end
