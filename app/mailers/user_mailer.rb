class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def preview user, claim
    @claim = claim
    attachments['eob.pdf'] = File.read(claim.file)
    mail(to: user.email, subject: 'Preview EOB')
  end
end
