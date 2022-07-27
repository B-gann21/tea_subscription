FactoryBot.define do
  factory :tea do
    title { Faker::JapaneseMedia::DragonBall.character }
    description { "a tasty tea from DBZ" }
    temperature { Faker::Number.between(from: 90, to: 110) }
    brew_time { Faker::Number.between(from: 5, to: 15) }
  end
end
