def handlers
  top_level_subscriptions
    .merge(Events.subscriptions)
end