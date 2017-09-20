require 'uri'
require 'json'
require 'net/http'

class GivveApiAccess
  @token = nil

  def initialize(token)
    data = {
      'token': token
    }
    @token = do_request('sessions/', 'POST', data)
  end

  def get_vouchers(id='')
   res = do_request('vouchers/' + id)
   JSON.parse(res)['data']
  end

  def get_vouchers_transactions(id)
    res = do_request('vouchers/' + id + '/transactions')
    JSON.parse(res)['data']
  end

  def update_customer(voucher_id, id, first_name, last_name)
    data = {
      'first_name': first_name,
      'last_name': last_name
    }
    res = do_request('vouchers/' + voucher_id + '/owners/' + id, 'PUT', data)
    JSON.parse(res)['data']
  end

  private

  def do_request(path, action='GET', params=nil)
    url = URI('https://www.givve.com/api/' + path)

    if action.eql?('POST')
      request = Net::HTTP::Post.new(url)
    else
      request = action.eql?('PUT') ? Net::HTTP::Put.new(url) : Net::HTTP::Get.new(url)
      request['accept-version'] = 'v2'
      request['authorization'] = @token
    end

    if not params.nil?
      request.set_form_data(params)
    end

    res = Net::HTTP.start(url.hostname, url.port,
                          use_ssl: url.scheme == 'https') { |http|
      http.request(request).body
    }
  end
end
