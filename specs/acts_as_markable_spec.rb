require File.join(File.dirname(__FILE__), 'spec_helper.rb')

class Picture < ActiveRecord::Base
  include Mark
  acts_as_markable :on => 'cover'
end


describe 'acts_as_markable' do
  load_schema

  
  describe 'Picture' do
  
    before(:each) do
      Picture.destroy_all
      Picture.acts_as_markable :on => 'cover', :max => 1, :allow_none => false
    end
    
    it 'should have mark options' do
      Picture.marking.should_not be_nil
      Picture.marking.class.should == Hash
      Picture.marking.size.should > 0
    end
    
    it 'should respond to mark scope' do
      lambda do
        Picture.marked
      end.should_not raise_error
    end
    
    it 'should mark an unmarked object' do
      p = create_non_cover_picture
      p.mark
      p.cover.should be_true
    end
    
    it 'should unmark a marked object' do
      Picture.acts_as_markable :on => 'cover', :max => 1, :allow_none => true
      p = create_cover_picture
      p.unmark
      p.cover.should be_false
    end
    
    it 'should return the last marked object' do
      p = create_cover_picture
      p.id.should == Picture.last_marked.first.id
    end
    
    describe "should have a maximum of #{Picture.marking[:max]} pictures marked" do
      
      it "when #{Picture.marking[:max]} gets marked" do
        create_some_pictures_with_max_marked
        p = create_cover_picture
        Picture.maximum_marked?.should be_true
        p.cover?.should be_true
      end
      
      it "when #{Picture.marking[:max].to_i-1} gets marked" do
        create_some_pictures_with_almost_max_marked
        p = create_cover_picture
        Picture.maximum_marked?.should be_true
        p.cover?.should be_true
      end
      
    end
    
    it "should create a maximum of #{Picture.marking[:max]} pictures marked when #{Picture.marking[:max]+1} gets marked" do
      max_pictures = Picture.marking[:max].to_i
      max_pictures.times do
        create_cover_picture
      end
      Picture.marked.count.should == max_pictures
      create_cover_picture
      Picture.marked.count.should == max_pictures
    end
    
    it 'should have last marked unmarked when a new object gets marked' do
      Picture.acts_as_markable :on => 'cover', :max => 1, :allow_none => true
      max_pictures = Picture.marking[:max].to_i
      p1 = create_non_cover_picture
      p1.cover?.should be_false
      p1.mark
      p1.cover?.should be_true
    
      p2 = create_non_cover_picture
      p2.cover?.should be_false
      p2.mark
      p2.cover?.should be_true
      p1.reload
      p1.cover?.should be_false
    
      p3 = create_cover_picture
      p3.cover?.should be_true
      p2.reload
      p2.cover?.should be_false
    
      p4 = create_cover_picture
      p4.cover?.should be_true
      p3.reload
      p3.cover?.should be_false
    end
    
    it 'should not unmark the last object when it gets unmarked and none is not allowed' do
      p = create_cover_picture
      p.unmark
      p.errors.should_not be_blank
      Picture.marked.count.should == 1
    end
    
    it 'should unmark the last object when it gets unmarked and none is allowed' do
      Picture.acts_as_markable :on => 'cover', :max => 1, :allow_none => true
      p = create_cover_picture
      p.unmark
      p.errors.should be_blank
      Picture.marked.count.should == 0
    end
    
    it 'should mark an unmarked object when the only marked has been deleted and still have unmarked objects' do
      p1 = create_non_cover_picture
      p2 = create_cover_picture
      Picture.marked.count.should == 1
      p2.destroy
      Picture.marked.count.should == 1
    end
    
    it 'should delete a marked object when it has been deleted and there is no unmarked object' do
      p = create_cover_picture
      Picture.marked.count.should == 1
      p.destroy
      Picture.marked.count.should == 0
      Picture.count == 0
    end
    
    
  
  end
  
  
  
end


def create_some_pictures_with_max_marked
  create_some_pictures_with_some_marked Picture.marking[:max]
end

def create_some_pictures_with_almost_max_marked
  create_some_pictures_with_some_marked Picture.marking[:max].to_i-1
end

def create_some_pictures_with_some_marked number_of_marked
  10.times do
    create_non_cover_picture
  end
  number_of_marked.to_i.times do
    create_cover_picture
  end
end

def create_non_cover_picture(options={})
  Picture.create picture_valid_attributes.merge(options).merge({:cover => false})
end

def create_cover_picture(options={})
  Picture.create picture_valid_attributes.merge(options).merge({:cover => true})
end

def create_picture(options={})
  Picture.create picture_valid_attributes.merge(options)
end


def picture_valid_attributes
  {
    :subtitle => 'Picture subtitle',
    :album => 'Album name',
    :cover => false
  }
end