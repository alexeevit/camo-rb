require 'spec_helper'

describe Camo::Server do
  it 'returns 200 Hello world' do
    get '/'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('Hello World')
  end
end
