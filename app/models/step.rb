class Step < ActiveRecord::Base
  belongs_to :parent, :class_name => Step
  belongs_to :algorithm, :class_name => Algorithm
end