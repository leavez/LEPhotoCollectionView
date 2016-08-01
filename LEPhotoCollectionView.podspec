Pod::Spec.new do |s|
  s.name         = "LEPhotoCollectionView"
  s.version      = "0.0.3"
  s.summary      = "CollectionView and cell for viewing images like Photo app"
  s.description  = <<-DESC
  A composite lib for viewing images.
  It have an CollectionView and cells, which should be used like any other
  collectionViews, which providing flexibilty.
                   DESC

  s.homepage     = "https://github.com/leavez/LEPhotoCollectionView"
  s.license      = "MIT"
  s.author             = "Leave"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/leavez/LEPhotoCollectionView.git", :tag => "0.0.3" }
  s.source_files  = "LEPhotoCollectionView/*.{h,m}"

end
