require 'spec_helper'

describe UserMailer do
  it '' do
    claim = create :claim
    user = claim.oxford.user
    mail = UserMailer.preview(user, claim)
    mail.to.should == [user.email]
    mail.subject.should == 'Preview EOB'
  end
end
