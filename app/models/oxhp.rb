require 'rubygems'
require 'mechanize'

class Oxhp
  def initialize oxford_credentials
    @oxford_credentials = oxford_credentials
    @agent = Mechanize.new if Rails.env.production?
    @agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE} unless Rails.env.production? # makes us vulnerable to man in the middle attacks :'( 

    login
    goto_claims_page
  end

  def get_new_claims
    num_eobs = @all_claims_page.search("#claims_sum_tbl tr").size - 2
    num_eobs.times.collect do |num|
      get_eob(num + 1)
    end.compact
  end

  def get_eob eob_number
    claim = Claim.new
    row = @all_claims_page.search("#claims_sum_tbl tr:nth-child(#{eob_number + 1})")
    claim.service_date = get_service_date row
    return nil if claim.service_date < Date.strptime('12/13/2013', '%m/%d/%Y')
    claim.service_code = get_service_code row
    claim.deductible_amount = get_deductible_amount row

    goto_claim_detail_page eob_number

    claim.claim_number = get_claim_number
    return nil if already_seen_claim_number?(claim.claim_number)
    upload_filename claim
    
    goto_claims_page
    claim.oxford_id = @oxford_credentials.id
    claim.save
    claim
  end

  def goto_claims_page
    puts 'goto claims page'
    @claims_page = @user_home_page.links.find { |l| l.text == 'Claims & Accounts' }.click
    show_all_claims
  end

  def goto_claim_detail_page eob_number
    puts 'goto claim detail page'
    link = @all_claims_page.links_with(text: 'More Details')[eob_number - 1]
    link.href =~ /'(\/Member.*)'/
    url = "#{domain}#{$1}"

    link.instance_variable_set(:@href, url)
    @claim_detail_page = link.click
  end

  def show_all_claims
    puts 'show all claims'
    form = @claims_page.form('claimsSummaryForm')
    form.dateOfService = 'all'
    @all_claims_page = @agent.submit(form, form.buttons.first)
  end

  def login
    puts "logging in"
    page = @agent.get(login_url)
    form = page.form('mem_login')
    form.j_username = @oxford_credentials.username
    form.j_password = @oxford_credentials.decrypt_password
    @user_home_page = @agent.submit(form, form.buttons.first)
  end

  def domain
    'https://www.oxhp.com'
  end

  def login_url
    "#{domain}/Member/MemberPortal/"
  end

  private
  def get_service_from_cell content
    return 'Lab' if content =~ /LB\d+/
    return 'Medical Office Visit' if content =~ /P\d+/
    return "NOT UNDERSTAND CODE #{content}"
  end

  def get_service_code row
    get_service_from_cell(row.search('td:nth-child(2)').first.content)
  end

  def get_service_date row
    row.search('td:nth-child(2)').first.content =~ /Service: (\d+\/\d+\/\d+)/
    Date.strptime($1, '%m/%d/%Y')
  end

  def get_deductible_amount row
    row.search('td:nth-child(5)').first.content.delete("$")
  end

  def get_claim_number
    @claim_detail_page.search('label[text()="Claim Number:"]').first.next_sibling.next_sibling.content
  end

  def upload_filename claim
    form = @claim_detail_page.form('claimsSummaryForm')
    file = @agent.submit(form, form.buttons.first)
    aws claim, file.body
  end

  def already_seen_claim_number? claim_number
    Claim.exists?(claim_number: claim_number)
  end

  def aws claim, pdf
    S3.new.write claim, pdf
  end

end
