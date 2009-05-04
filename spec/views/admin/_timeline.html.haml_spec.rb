require File.dirname(__FILE__) + '/../../spec_helper'

describe "/admin/_timeline.html.haml" do
  dataset :versions
  
  before(:each) do
    template.send :extend, Admin::TimelineHelper
  end
  
  describe "when used in the context of a page" do
    it "should have a node for the working version, which I am currently editing" do
      assigns[:page] = pages(:draft)
      render 'admin/_timeline.html.haml'
      response.should have_selector("li", :id=>"working-version") do |li|
        li.should have_marker(:this)
      end
    end
  end
  
  describe "when used in the context of a version" do
    before(:each) do
      assigns[:version] = pages(:draft).versions.current
      assigns[:page] = pages(:draft)
    end

    it "should have a chevron on the version I am currently viewing" do
      render 'admin/_timeline.html.haml'
      response.should have_selector("li", :id=>"version-1") do |li|
        li.should have_marker(:this)
      end
    end
    
    it "should not have a working version node" do
      render 'admin/_timeline.html.haml'
      response.should_not have_selector("li", :id=>"working-version")
    end
  end
  
  
  it "should produce a dev flag on a first-version draft" do
    assigns[:page] = pages(:draft)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:draft) do |li|
      li.should have_marker(:dev)
    end
  end

  it "should produce a dev flag on a first-version reviewed page" do
    assigns[:page] = pages(:reviewed)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:reviewed) do |li|
      li.should have_marker(:dev)
    end
  end

  it "should produce a dev+live flag on a first-version hidden page" do
    assigns[:page] = pages(:hidden)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:hidden) do |li|
      li.should have_marker("dev-and-live")
    end
  end

  it "should produce a live flag on live version of published page with draft" do
    assigns[:page] = pages(:page_with_draft)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:published) do |li|
      li.should have_marker(:live)
    end
  end
  
  it "should produce a dev flag on current version of published page with draft" do
    assigns[:page] = pages(:page_with_draft)
    render 'admin/_timeline.html.haml'
    response.should have_version(2).as(:draft) do |li|
      li.should have_marker(:dev)
    end
  end
  
  it "should produce a live+dev flag on a current published page" do
    assigns[:page] = pages(:published)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:published) do |li|
      li.should have_marker("dev-and-live")
    end
  end
  
  it "should not put a marker on a published version that is not current live" do
    assigns[:page] = pages(:published_with_many_versions)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:published) do |li|
      li.should_not have_marker
    end
  end
  
  it "should not put a marker on a draft version that is not current dev" do
    assigns[:page] = pages(:draft_with_many_versions)
    render 'admin/_timeline.html.haml'
    response.should have_version(1).as(:draft) do |li|
      li.should_not have_marker
    end
  end
  
  it "should make the line fade out when the timeline does not begin with version 1" do
    pending # timeline limit is not implemented yet, but class="beginning" on the LI will make the line fade
  end
  
  def have_marker(type=nil)
    opts = {:class=>"marker"}
    if type
      type = type.to_s
      opts.merge! :id=>"#{type}-marker", :src=>"/images/admin/#{type}.png"
    end
    have_selector("img", opts)
  end
  
end