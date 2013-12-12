class S3
  def initialize
    @s3 = AWS::S3.new(:access_key_id => ENV['AWS_ACCESS_KEY_ID'], :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'])
    @bucket = @s3.buckets['health_insurance']
  end

  def write claim, pdf
    obj = @bucket.objects["#{claim.claim_number}.pdf"]
    obj.write(pdf, :server_side_encryption => :aes256)
  end

  def delete claim
    obj = @bucket.objects["#{claim.claim_number}.pdf"]
    obj.delete
  end

  def read claim
    obj = @bucket.objects["#{claim.claim_number}.pdf"]
    obj.read
  end
end
