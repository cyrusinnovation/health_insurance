require 'rubygems'
require 'mechanize'

class Oxhp
  def initialize claimant, relationship
    @claimant = claimant
    @relationship = relationship
    @agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE} # succeptable to man-in-the-middle attacks
  end

  def get_new_claims
    login
    goto_claims_page
    show_all_claims
    get_eob 1
  end

  def get_eob eob_number
    row = @all_claims_page.search("#claims_sum_tbl tr:nth-child(#{eob_number + 1})")
    service_date = get_service_date row
    service_code = get_service_code row
    deductible_amount = get_deductible_amount row

    goto_claim_detail_page eob_number

    claim_number = get_claim_number
    filename = get_filename
    [Claim.new(service_date, service_code, deductible_amount, @claimant, @relationship, filename)]
  end

  def goto_claims_page
    @claims_page = @user_home_page.links.find { |l| l.text == 'Claims & Accounts' }.click
  end

  def goto_claim_detail_page eob_number
    link = @all_claims_page.links_with(:text => 'More Details')[eob_number - 1]
    link.href =~ /'(\/Member.*)'/
    url = "#{domain}#{$1}"

    link.instance_variable_set(:@href, url)
    @claim_detail_page = link.click
  end

  def show_all_claims
    form = @claims_page.form('claimsSummaryForm')
    form.dateOfService = 'all'
    @all_claims_page = @agent.submit(form, form.buttons.first)
  end

  def login
    page = @agent.get(login_url)
    form = page.form('mem_login')
    form.j_username = ENV['USER']
    form.j_password = ENV['PASSWORD']
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
    $1
  end

  def get_deductible_amount row
    row.search('td:nth-child(5)').first.content.delete("$")
  end

  def get_claim_number
    @claim_detail_page.search('label[text()="Claim Number:"]').first.next_sibling.next_sibling.content
  end

  def get_filename
    form = @claim_detail_page.form('claimsSummaryForm')
    file = @agent.submit(form, form.buttons.first)
    filename = "/Users/jacobodonnell/programming/health_insurance/tmp/#{file.filename}"
    file.save filename
    filename
  end

end
