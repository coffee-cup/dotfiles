  # Sample Maid rules file -- some ideas to get you started.
#
# To use, remove ".sample" from the filename, and modify as desired.  Test using:
#
#     maid clean -n
#
# **NOTE:** It's recommended you just use this as a template; if you run these rules on your machine without knowing
# what they do, you might run into unwanted results!
#
# Don't forget, it's just Ruby!  You can define custom methods and use them below:
# 
#     def magic(*)
#       # ...
#     end
# 
# If you come up with some cool tools of your own, please send me a pull request on GitHub!  Also, please consider sharing your rules with others via [the wiki](https://github.com/benjaminoakes/maid/wiki).
#
# For more help on Maid:
#
# * Run `maid help`
# * Read the README, tutorial, and documentation at https://github.com/benjaminoakes/maid#maid
# * Ask me a question over email (hello@benjaminoakes.com) or Twitter (@benjaminoakes)
# * Check out how others are using Maid in [the Maid wiki](https://github.com/benjaminoakes/maid/wiki)

Maid.rules do

  HOME_DIR = '/Users/susie'
  PREV_DOWNLOADS_DIR = "#{HOME_DIR}/Downloads/Older Than 30 Days"
  DOWNLOADS_DIR = "#{HOME_DIR}/Downloads"

  def updateSystem()
    pid = Process.spawn("brew update;brew upgrade --all")
    Process.detach pid
    pid = Process.spawn("npm update -g")
    Process.detach pid
  end

  # < day - Red
  # > day, < 2 days - Orange
  # > 2 days, < 5 days - Yellow
  # > 5 days, < 10 days - Green
  # > 10 days, < 20 days - Blue
  # > 20 days, < 30 days - Purple
  # Labels file based on date since now
  def colourFile(path)
    # set_tag(path, [])
    
    days = daysSince(path)
    # puts "#{days} days for #{path}"

    if days <= 0
      set_tag(path, "Red")
    elsif days <= 2
      set_tag(path, "Orange")
    elsif days <= 5
      set_tag(path, "Yellow")
    elsif days <= 10
      set_tag(path, "Green")
    elsif days <= 20
      set_tag(path, "Blue")  
    elsif days <= 30
      set_tag(path, "Purple")
    else
      set_tag(path, [])
    end
  end

  def moveOldDownload(path)
    days = daysSince(path)

    if days > 30
      set_tag(path, [])
      move(path, "#{PREV_DOWNLOADS_DIR}/")
    end
  end


  # Cleans up downloads folder
  # Labels recent downloads
  # Moves old ones
  def cleanDownloads()
    dir("#{DOWNLOADS_DIR}/*").each do |path|
      if path != PREV_DOWNLOADS_DIR
        colourFile(path)
        moveOldDownload(path)
      end
    end
  end

  # returns days since path was last accessed
  def daysSince(path)
    now = Time.now
    days = (now - accessed_at(path)).to_i / (24 * 60 * 60)
    return days
  end

  def clearTags(path)
    set_tag(path, [])
  end

  # Watch downloads folder to label and move old downloads
  watch '~/Downloads/' do
    rule 'Colour Downloads Watch' do
      cleanDownloads()
    end
  end

  # Run everyday to label and move old downloads
  repeat '1d' do
    rule 'Colour Downloads Daily' do
      cleanDownloads()
    end
  end

  rule 'Run all' do
    cleanDownloads()
    updateSystem()
  end

  # Updates packages on system
  repeat '1d' do
    rule 'Update System' do
      updateSystem()
    end
  end

end
