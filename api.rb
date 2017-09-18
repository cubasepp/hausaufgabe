require 'uri'
require 'json'
require 'net/http'

class GivveApiAccess
  @token = nil

  def initialize(token)
    @token = do_post('sessions/', {'token': token})
  end

  def get_vouchers(id=nil)
    return do_get('vouchers/' + (id || ''))
  end

  def get_vouchers_transactions(id)
    return do_get('vouchers/' + id + '/transactions')
  end

  def get_customer(id)
    return do_get('customers/' + id)
  end

  def update_customer(voucher_id, id, first_name, last_name)
    return do_post('vouchers/' + voucher_id + '/owners/' + id,
      {'first_name': first_name, 'last_name': last_name},
      true)
  end

  private
  def do_post(path, data, put=nil)
    url = URI('https://www.givve.com/api/' + path)
    if put.nil?
      request = Net::HTTP::Post.new(url)
    else
      request = Net::HTTP::Put.new(url)
      request["accept-version"] = 'v2'
      request["authorization"] = @token

    end
    request.set_form_data(data)

    return res = Net::HTTP.start(url.hostname, url.port,
      :use_ssl => url.scheme == 'https') {|http|
      http.request(request).body
    }
  end

  def do_get(path)
    url = URI('https://www.givve.com/api/' + path)
    request = Net::HTTP::Get.new(url)

    request["accept-version"] = 'v2'
    request["authorization"] = @token

    return res = Net::HTTP.start(url.hostname, url.port,
      :use_ssl => url.scheme == 'https') {|http|
      JSON.parse(http.request(request).body)['data']
    }
  end
end
