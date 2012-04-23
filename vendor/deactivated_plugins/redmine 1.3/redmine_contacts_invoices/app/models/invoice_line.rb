class InvoiceLine < ActiveRecord::Base
  unloadable
  belongs_to :invoice
  
  validates_presence_of :description, :price, :quantity
  validates_uniqueness_of :description, :scope => :invoice_id
  validates_numericality_of :price, :quantity
  
  acts_as_list :scope => :invoice
  
  def total
    price.to_f * quantity.to_f
  end

  def tax_amount
    (tax.to_f / 100) * total.to_f
  end
  
end
