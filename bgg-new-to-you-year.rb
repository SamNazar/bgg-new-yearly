#!/usr/bin/env ruby

# This is a modified version of Wes Baker's New-To-You script, which was designed to 
# list new games for a particular month and output a skeleton geeklist post with 
# ratings.
# 
# The modified script merely lists the new games a user has logged in a given calendar year
# and provides a count of those games.  This is to keep track of challenges like 51-in-15
# 
# TODO: If year is not current year, end date should be Dec 31 of that year
# TODO: It seems that this is making a new request for each new game, fix this
# 

require 'date'
require 'optparse'
require 'open-uri'
require 'nokogiri'
require './game'

class NewToYouYear
  def initialize
    todays_date = Date.today
    @options = {
      :username     => 'sam n',
      :year         => todays_date.year,
    }

    parse_options

    ## start at beginning of year given
    @options[:start_date] = Date.parse(@options[:year].to_s + "-01-01")

    ## end at today
    @options[:end_date] = todays_date

    print_games(retrieve_plays())
  end

  # Parse out command line options
  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Retrieve a listing of games that were new to you.
    Usage: bgg-new-to-you-year.rb --username UserName --year 2015"

      opts.on('-u username', '--username username', "Username") do |username|
        @options[:username] = username.to_s
      end

      opts.on('-y YEAR', '--year YEAR', 'Year (four digits, e.g. 2015)') do |year|
        @options[:year] = year.to_i
      end
    end.parse!
  end

  def retrieve_plays(start_date = @options[:start_date], end_date = @options[:end_date], username = @options[:username])
    # Retrieve games played in year
    plays = BGG_API.new('plays', {
      :username => username,
      :mindate  => start_date,
      :maxdate  => end_date,
      :subtype  => 'boardgame'
    }).retrieve

    _games = Hash.new

    # First, get this year's plays
    plays.css('plays > play').each do |play|
      quantity = play.attr('quantity')
      item = play.search('item')
      name = item.attr('name').content
      objectid = item.attr('objectid').content.to_i

      # Create the hashes if need be
      unless _games.has_key? objectid
        _games[objectid] = Game.new
        _games[objectid][:objectid] = objectid
        _games[objectid][:name] = name
      end

      # Increment play count
      _games[objectid][:plays] = _games[objectid][:plays] + quantity.to_i
    end

    _games.each do |objectid, data|
      # Filter out games I've played before (before mindate)
      puts "Making BGG Request for previous plays"
      previous_plays = BGG_API.new('plays', {
        :username => username,
        :maxdate  => start_date,
        :id       => objectid
      }).retrieve

      if previous_plays.css('plays').first['total'].to_i > 0
        _games.delete(objectid)
        next
      end
    end
  end

  def print_games(_games)
    # Print each game's name
    _games.each do |objectid, data|
      puts data[:name]
    end
    # print total number of new games this year
    puts _games.length.to_s + " new games played in " + @options[:year].to_s + "."
  end

  public :initialize
  private :parse_options, :retrieve_plays
end

# BGG API class that pulls in data and takes a hash as a set of options for the
# query string
class BGG_API
  @@bgg_api_url = "https://boardgamegeek.com/xmlapi2"

  def initialize(type, options)
    @type = type
    @options = options
  end

  def set_options(options)
    @options = @options.merge(options)
  end

  def retrieve
    query = "#{@@bgg_api_url}/#{@type}?"

    @options.each do |name, value|
      query << "#{name}=#{value}&"
    end

    # Remove the last ampersand
    query = query[0..-2]

    # Make sure we're receving a 200 result, otherwise wait and try again
    request = open(query)
    while (request.status[0] != "200")
      sleep 2
      request = open(query)
    end

    Nokogiri::XML(request.read)
  end
end

NewToYouYear.new
