class SubmitEobs
  def initialize
    Claim.ready_for_submitting.each do |claim|
      uploader = ClaimUploader.new
      uploader.submit_claim claim
      claim.mark_as_submitted
    end
  end
end
