module Mark

  # Includes all the necessary instance methods to ActiveRecord Models
  # @see InstanceMethods
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  
  # Add the <tt>acts_as_markable</tt> method to all ActiveRecord models.
  module ClassMethods
    
    
    # Makes the model acts as markable
    def acts_as_markable options={}
      
      options = {
        :on => 'checked',     # fields to handle the mark
        :max => 1,            # max of records that can be marked within the same scope
        :allow_none => true   # whether or not is allowed to have no records marked
      }.merge(options)
      
      self.class_eval do
        cattr_accessor :mark
        self.mark = options
        scope :marked, lambda { where("#{self.mark['on']}" => true) }
        send :include, InstanceMethods
      end
      
    end
    
    
  end
  
  
  
  # Instance methods for markable models
  module InstanceMethods

    def mark
    end
    
  end
  
  
end

ActiveRecord::Base.send :include, Mark