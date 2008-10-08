require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Video do

  describe "validations" do

    before :each do
      @video = Factory(:video)
    end
    
    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should require the presence of a title" do
      @video.should be_valid
      @video.title = nil
      @video.should_not be_valid
    end
    
    it "should require the presence of a sentence" do
      @video.should be_valid
      @video.sentence = nil
      @video.should_not be_valid
    end
    
  end

  describe "descriptors" do

    before :each do
      @video = Factory(:video)
      @type = DescriptorType.create! :title => "some descriptor"
      @value = Descriptor.create! :descriptor_type => @type,
      :text => "some descriptor"
    end

    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should start as an empty set" do
      @video.descriptors.should == []
    end

    it "should allow descriptors to be added" do
      @video.descriptors << @value
      @video.should be_valid
      @video.save.should be_true
    end

    it "should require they be unique" do
      @video.descriptors << @value
      # the join table  so no chance for the validation to run
      lambda { @video.descriptors << @value }.should raise_error
    end

  end

  describe ".recent" do
    fixtures :videos

    it "should return the most recent video (shortcut for .find ...)" do
      Video.recent[0].should == ( Video.find :first, :order => "created_at desc" )
    end

    it "should return the n most recent videos (shortcut for .find ...)" do
      Video.recent(3).should ==
        ( Video.find :all, :order => "created_at desc", :limit => 3 )
    end

  end

  describe "fulltext" do

    before(:each) do
      @string = "just_for_this_test"
      @video = Factory.build :video, :sentence => @string
    end

    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should insert into FT table on save" do
      @video.id.should be_nil
      ( Video.search :query => @string ).should be_empty
      @video.save!
      ( Video.search :query => @string )[0].should == @video
    end

    it "should delete from FT table on destroy" do
      @video.save!
      ( Video.search :query => @string )[0].should == @video
      @video.destroy
      ( Video.search :query => @string ).should be_empty
    end

    it "should update FT table on update" do
      @video.save!
      ( Video.search :query => @string )[0].should == @video
      @new_string = "isnt_the_same"
      @video.sentence = @new_string
      @video.save!
      ( Video.search :query => @string ).should be_empty
      ( Video.search :query => @new_string )[0].should == @video
    end

    it "should normal not return a pagination object" do
      @video.save!
      ( WillPaginate::Collection ===
        ( Video.search :query => @string ) ).should be_false
    end

    it "should normal not return a pagination object" do
      @video.save!
      ( WillPaginate::Collection ===
        ( Video.search :query => @string, :method => :paginate ) ).
        should be_true
    end

  end

  describe "descriptors/type recall and sorting" do

    before(:each) do
      @video = Factory(:video)
      @dts = [ DescriptorType.create!( :title => "a", :priority => 2 ),
               DescriptorType.create!( :title => "b", :priority => 1 ),
               DescriptorType.create!( :title => "c", :priority => 3 ),
               DescriptorType.create!( :title => "d", :priority => 4 ) ]
      @dss = [ Descriptor.create!( :descriptor_type => @dts[0],
                                    :text => "aa", :priority => 2 ),
               Descriptor.create!( :descriptor_type => @dts[0],
                                    :text => "ab", :priority => 1 ),
               Descriptor.create!( :descriptor_type => @dts[0],
                                    :text => "ac", :priority => 3 ),
               Descriptor.create!( :descriptor_type => @dts[1],
                                    :text => "ba", :priority => 1 ),
               Descriptor.create!( :descriptor_type => @dts[2],
                                    :text => "ba", :priority => 1 ) ]
      @video.descriptors = @dss
      @video.save!
    end

    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should return all the types for a video in pri order" do
      @video.descriptor_types.should == [ @dts[1], @dts[0], @dts[2] ]
    end
    
    it "should return all the descriptors for a video in pri order" do
      @video.descriptors_by_type( @dts[0] ).
        should == [ @dss[1], @dss[0], @dss[2] ]
      @video.descriptors_by_type( @dts[1] ).should == [ @dss[3] ]
      @video.descriptors_by_type( @dts[2] ).should == [ @dss[4] ]
    end
    
  end

  describe "property interface to video" do

    before(:each) do
      @video = Factory(:video)
    end

    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should allow a property to be added" do
      @video.properties << Property.build( "Producer", "Frank Capra" )
      @video.save!
    end

    describe "property operations" do

      before(:each) do

        @video.properties <<
          Property.new( :property_type =>
                        PropertyType.find_by_name( "Producer" ),
                        :value => "Frank Capra" )

        @video.properties << Property.build( "Producer", "George Lucas" )
        @video.properties << Property.build( "Writer", "Stephen King" )
        @video.properties << Property.build( "Broadcast", "10/25/2005" )
        @video.properties << Property.build( "Production", "10/25/2005" )

        @video.save!

        @retrieved = Video.find @video.id

      end

      it "should find properties" do
        @retrieved.properties.find_all_by_type( "Producer" ).size.should == 2
      end

      it "should list by class" do
        @retrieved.properties.find_all_by_class( "Roles" ).size.should == 3
        @retrieved.properties.find_all_by_class( "Collections" ).size.
          should == 0
      end

      it "should search by property values"  do
        @retrieved = Video.search :query => "George Lucas"
        @retrieved.size.should == 1
      end

      it "should require required properties" do

        pc = PropertyClass.create! :name => "myclass",
                                    :multivalued => false,
                                    :optional => false,
                                    :range => :string
        pt = PropertyType.create! :property_class_id => pc.id,
                                   :name =>  "mytype"

        @video.save.should be_false

      end

      it "should allow multivalued where appropriate"  do
        @video.properties << Property.build( "Producer", "Steven Spielberg" )
        @video.save.should be_true
      end

      it "should prohbit multivalued where appropriate"  do

        pc = PropertyClass.create! :name => "myclass",
                                    :multivalued => false,
                                    :optional => false,
                                    :range => :string

        pt = PropertyType.create! :property_class_id => pc.id,
                                   :name =>  "mytype"

        @video.save.should be_false

        @video.properties << Property.build( "mytype", "foo" )
        @video.save.should be_true

        @video.properties << Property.build( "mytype", "bar" )
        @video.save.should be_false
      end

    end

  end

  describe "descriptor properties" do

    before(:each) do
      @video = Factory(:video)
    end

    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should allow a property descriptor to be added" do
      @video.properties << Property.build( "Genre", "Documentary" )
      @video.save.should be_true
    end

    it "should not allow a property descriptor to be added multiple times" do
      @video.properties << Property.build( "Genre", "Documentary" )
      @video.properties << Property.build( "Genre", "Documentary" )
      @video.save.should be_false
    end

    it "should require mandatory descriptors" do
      pc = PropertyClass.find_by_name "Mandatory Multivalued Descriptor"
      pt = PropertyType.create! :name => "mytype",
                                 :property_class => pc
      dv = DescriptorValue.create! :property_type => pt,
                                     :value => "myvalue"
      @video.save.should be_false
      @video.properties << Property.build( "mytype", "myvalue" )
      @video.save.should be_true
    end

    it "should disallow mv descriptors when sv" do
      pc = PropertyClass.find_by_name "Mandatory Singular Descriptor"
      pt = PropertyType.create! :name => "mytype",
                                 :property_class => pc
      DescriptorValue.create! :property_type => pt, :value => "myvalue"
      DescriptorValue.create! :property_type => pt, :value => "myvaluex"
      @video.save.should be_false
      @video.properties << Property.build( "mytype", "myvalue" )
      @video.save.should be_true
      @video.properties << Property.build( "mytype", "myvaluex" )
      @video.save.should be_false
    end

    it "should allow mv descriptors when mv" do
      pc = PropertyClass.find_by_name "Optional Multivalued Descriptor"
      pt = PropertyType.create! :name => "mytype",
                                 :property_class => pc
      DescriptorValue.create! :property_type => pt, :value => "myvalue"
      DescriptorValue.create! :property_type => pt, :value => "myvaluex"
      @video.save.should be_true
      @video.properties << Property.build( "mytype", "myvalue" )
      @video.save.should be_true
      @video.properties << Property.build( "mytype", "myvaluex" )
      @video.save.should be_true
    end

  end

end
