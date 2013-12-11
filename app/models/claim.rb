class Claim
  attr_reader :service_date, :service_code, :deductible_amount, :file, :claimant, :relationship, :number

  def initialize service_date, service_code, deductible_amount, claimant, relationship, number, file
    @service_date = service_date # '1/9/2013' or '12/12/2013'
    @service_code = service_code # 'Medical Office Visit' or 'Lab'
    @deductible_amount = deductible_amount # '10.23'
    @file = file # filename
    @claimant = claimant # 'Bobby McWilliams'
    @relationship = relationship # 'Spouse' or 'Self'
    @number = number
  end

  def mark_as_processed
    Eob.create claim_number: number
  end
end
