class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { customer: 0, technician: 1, admin: 2 }

  has_many :service_requests,          foreign_key: :customer_id,   dependent: :destroy
  has_many :assigned_service_requests, foreign_key: :technician_id, dependent: :nullify,
                                       class_name: "ServiceRequest"
  has_many :service_notes,             foreign_key: :technician_id, dependent: :destroy
  has_many :sent_messages,             foreign_key: :sender_id,     dependent: :destroy,
                                       class_name: "Message"
  has_many :notifications,             dependent: :destroy

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
