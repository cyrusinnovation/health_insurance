class Claim < ActiveRecord::Base
  belongs_to :oxford

  def self.ready_for_submitting
    Claim.where("created_at < ?", 1.hour.ago).where(state: 'unprocessed')
  end

  def mark_as_submitted
    self.state = 'submitted'
    # delete file
    save
  end

  def mark_as_canceled
    self.state = 'canceled'
    # delete file
    save
  end

  def claimant
    oxford.claimant
  end

  def relationship
    oxford.relationship
  end

  def ready_for_processing?
    state == 'unprocessed'
  end

  def user
    oxford.user
  end
end
