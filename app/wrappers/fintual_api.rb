class FintualApi
  def initialize(external_account)
    @email = external_account.username
    @token = external_account.access_token
  end

  def fetch_goals
    response = HTTParty.get(
      "https://fintual.cl/api/goals",
      query: {
        user_email: email,
        user_token: token
      }
    )

    response.parsed_response["data"].map do |goal|
      {
        id: goal["id"],
        name: goal["attributes"]["name"],
        created_at: goal["attributes"]["created_at"],
        nav: goal["attributes"]["nav"],
        profit: goal["attributes"]["profit"],
        not_net_deposited: goal["attributes"]["not_net_deposited"],
        deposited: goal["attributes"]["deposited"],
        withdrawn: goal["attributes"]["withdrawn"]
      }
    end
  end

  private

  attr_reader :email, :token
end
