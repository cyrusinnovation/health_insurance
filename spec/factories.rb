FactoryGirl.define do
  sequence(:email) {|n| "email#{n}@example.com" }
  
  factory :user do
    email { generate(:email) }
    password '12345678'
  end

  factory :oxford do
    username 'bobby'
    password '123456'
    claimant 'Bobby Doe'
    relationship 'Self'
    user
  end

  factory :myrsc do
    username 'boby'
    password '123456'
    user
  end

  factory :claim do
    service_date Date.strptime('12/12/2013', '%m/%d/%Y')
    service_code 'Lab'
    deductible_amount 10.23
    claim_number '1234'
    state 'unprocessed'
    file 'eob.pdf'
    oxford
  end
end
