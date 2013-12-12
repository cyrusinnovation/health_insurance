class ClaimUploader
  def initialize
    @agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE} # succeptable to man-in-the-middle attacks
  end

  def submit_claim claim
    login claim
    select_role
    goto_claims_entry_page_1
    goto_claims_entry_page_2
    goto_claims_entry_page_3
    enter_claim claim
  end
  
  def login claim
    page = @agent.get(domain)
    form = page.form('login')
    form.logperson = claim.oxford.user.myrsc.username
    form.logpass = claim.oxford.user.myrsc.password
    @role_select_page = @agent.submit(form, form.buttons.first)
  end

  def select_role
    form = @role_select_page.forms.first
    form.field_with(name: 'role').options.each {|companies| companies.select if companies.text =~ /Cyrus Innovation/}
    @home_page = @agent.submit(form, form.buttons.first)
  end

  def goto_claims_entry_page_1
    weird_redirect_page = @home_page.link_with(:text => 'Online Claims Entry').click
    @claims_entry_page_1 = @agent.submit(weird_redirect_page.forms.first, weird_redirect_page.forms.first.buttons.first)
  end

  def goto_claims_entry_page_2
    new_page_form = @claims_entry_page_1.form('form1')
    @claims_entry_page_2 = @agent.submit(new_page_form, new_page_form.buttons.find {|x| x.value == 'Start New Claim Form'})
  end

  def goto_claims_entry_page_3
    form = @claims_entry_page_2.form('form1')
    form.add_field!('__EVENTARGUMENT', '')
    form.add_field!('__EVENTTARGET', 'CtrlOnlineClaimForm1$enterMedicalLink')
    @enter_claim_page = form.submit
  end

  def enter_claim claim
    form = @enter_claim_page.form('form1')
    form['CtrlOnlineClaim1$amountBox'] = claim.deductible_amount
    form.field_with(name: 'CtrlOnlineClaim1$serviceDropDown').options.find {|x| x.text == claim.service_code}.select
    form['CtrlOnlineClaim1$startDateBox_input'] = claim.service_date
    form['CtrlOnlineClaim1$endDateBox_input'] = claim.service_date
    form['CtrlOnlineClaim1$claimantBox'] = claim.claimant
    form['CtrlOnlineClaim1$relationshipBox'] = claim.relationship
    #form.file_uploads.first.file_name = 
    form.file_uploads.first.file_data = S3.new.read(claim)
    form.file_uploads.first.mime_type = 'application/pdf'
    form
    #@agent.submit(form, form.buttons_with(value: 'Save this Claim'))
  end

  def domain
    'https://myrsc.com'
  end
end
