class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { customer: 0, technician: 1, admin: 2 }

  # Prevent role from being mass-assigned through public params
  attr_readonly :role

  validates :role, presence: true

  # Devise hook — deactivated accounts cannot sign in
  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :account_deactivated
  end
end
