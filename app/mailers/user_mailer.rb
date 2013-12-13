class UserMailer < ActionMailer::Base
  default from: "no-reply@cyrusinnovation.com"

  def preview user, claim
    @claim = claim
    attachments['eob.pdf'] = S3.new.read(claim)
    mail(to: user.email, subject: 'Preview EOB')
  end
end
