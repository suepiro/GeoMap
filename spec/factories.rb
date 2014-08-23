FactoryGirl.define do
	factory :user do
		name "wataru"
		email "wataru@example.com"
		password "foobar"
		password_confirmation "foobar"
	end
end