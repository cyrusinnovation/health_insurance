class FindNewEobs
  def initialize
    User.all.each do |user|
      user.oxfords.each do |oxford|
        puts "logging in as #{oxford.username}"
        begin
          oxhp = Oxhp.new oxford
          claims = oxhp.get_new_claims
          claims.each do |claim|
            UserMailer.preview(user, claim).deliver
          end
        rescue
          puts 'user had error'
        end
      end
    end
  end
end
