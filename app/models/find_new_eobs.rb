class FindNewEobs
  def initialize
    User.all.each do |user|
      user.oxfords.each do |oxford|
        puts "logging in as #{oxford.username}"
        oxhp = Oxhp.new oxford
        claims = oxhp.get_new_claims
        claims.each do |claim|
          claim.mark_as_processed
          UserMailer.preview(user, claim).deliver
        end
      end
    end
  end
end
