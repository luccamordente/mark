require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class Picture < ActiveRecord::Base
  include Mark
  
  acts_as_markable
end

describe 'acts_as_rankable' do
  load_schema
  
  
  describe 'Picture' do
    
    it 'should have mark options' do
      Picture.mark.should_not be_nil
      Picture.mark.class.should == Hash
      Picture.mark.size.should > 0
    end
    
    it 'should respond to mark scope' do
      lambda do
        Picture.marked
      end.should_not raise_error
    end
    
    
  
  end
  
  
  
end