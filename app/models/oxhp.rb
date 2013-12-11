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
    first_eob
  end

  def first_eob
    first_row = @all_claims_page.search('#claims_sum_tbl tr:nth-child(2)')
    first_row.search('td:nth-child(2)').first.content =~ /Service: (\d+\/\d+\/\d+)/
    service_date = $1
    service_code = get_service_from_cell(first_row.search('td:nth-child(2)').first.content)
    deductible_amount = first_row.search('td:nth-child(5)').first.content.delete("$")
    link = @all_claims_page.links_with(:text => 'More Details')[0]
    link.href =~ /'(\/Member.*)'/
    url = "#{domain}#{$1}"

    link.instance_variable_set(:@href, url)
    link.instance_variable_set(:@uri, nil)
    claim_detail_page = link.click

    form = claim_detail_page.form('claimsSummaryForm')
    file = @agent.submit(form, form.buttons.first)
    filename = "/Users/jacobodonnell/programming/health_insurance/tmp/#{file.filename}"
    file.save filename # or .body
    [Claim.new(service_date, service_code, deductible_amount, @claimant, @relationship, filename)]
  end

  def goto_claims_page
    @claims_page = @user_home_page.links.find { |l| l.text == 'Claims & Accounts' }.click
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
    return 'Medical Office Visit'
  end
end
