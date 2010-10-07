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
        before_save :set_last_marked_at, :check_mark
        before_destroy :check_mark_for_destroy
        
        cattr_accessor :marking
        self.marking = options
        
        scope :marked, lambda { where("#{self.marking[:on]}" => true) }
        scope :last_marked, lambda { marked.order("last_marked_at DESC").limit(1) }
        scope :last_marked_unmarked, lambda { where("#{self.marking[:on]}" => false).order("last_marked_at DESC").limit(1) }
        
        send :include, InstanceMethods
      end
      
    end
    
    
  end
  
  
  
  # Instance methods for markable models
  module InstanceMethods
    
    def self.included(base)
      base.send :extend, ClassMethods
    end

    def mark
      @is_marking = true
      self.class.last_marked.first.unmark(false) if self.class.maximum_marked?
      update_attribute self.class.mark_attribute, true
    end
    
    def unmark(check=true)
      @is_marking = true
      if check and self.class.minimum_marked? and not self.class.allow_none_marked?
        errors.add(:base, 'At least one object must remain maked.')
      else
        update_attribute self.class.mark_attribute, false
      end
    end
    
    module ClassMethods
      def maximum_marked?
        marked.count == marking[:max].to_i
      end
      
      def minimum_marked?
        marked.count == 1
      end
      
      def allow_none_marked?
        marking[:allow_none]
      end
      
      def mark_attribute
        marking[:on].to_sym
      end
    end
    
    private
    
      def set_last_marked_at
        self.last_marked_at = Time.now if marked?
      end
      
      def check_mark
        return true if @is_marking
        if marked?
          mark
        else
          unmark
        end
        true
      end
      
      def check_mark_for_destroy
        return true unless marked? or self.class.count == 1
        last_marked_unmarked = self.class.last_marked_unmarked
        unless last_marked_unmarked.blank?
          last_marked_unmarked.first.mark
        else
          self.class.first.mark
        end
        true
      end
      
      def marked?
        eval "#{marking[:on]}?"
      end
    
  end
  
  
end

ActiveRecord::Base.send :include, Mark