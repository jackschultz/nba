Koudoku.setup do |config|
  config.webhooks_api_key = "b4eec682-a481-4161-beb7-a57f4008350a"
  config.subscriptions_owned_by = :user
  config.stripe_publishable_key = ENV['STRIPE_PUBLISHABLE_KEY']
  config.stripe_secret_key = ENV['STRIPE_SECRET_KEY']
  # config.free_trial_length = 30
end
