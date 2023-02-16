# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  scope :latest, -> { order(created_at: :desc) }
end
