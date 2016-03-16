#BoardGameGeek New to You This Year Script

I wanted to see how many new games I'd played this year.  This script will list your new games logged on BGG in the last year and give you a total.

This started out as a modified version of @wesbaker's script, which he wrote for the monthly New-to-You GeekList.  It was modified to handle the larger number of plays that can occur in a year vs. a month.  Big thanks to Wes for the original.

## Installing

First and foremost, you'll need at least Ruby 1.9.2 due to Nokogiri. After that,
you should use [bundler](http://bundler.io) to install the required gems:

```
bundle install
```

You might also have to change permissions to make the script executable:

```
chmod +x bgg-new-to-you-year.rb
```

## Using

Once everything's loaded, run the script like so:

```
./bgg-new-to-you-year.rb --username <your_username>
```
    
Remember to put your username in quotes if it includes a space.

By default the script will retrieve plays for the current year, if you need to
pick a different year you can:

```
./bgg-new-to-you-year.rb --username <your_username> --year 2012
```

## Command line options
* `-u` or `--username`: **REQUIRED**.
* `-y` or `--year`: The year for which to look up plays.  Default is the current year.
* `-o` or `--order`: How to order the results.  Default is alphabetically
    - `alpha`: sort alphabetically by game name
    - `plays`: descending by number of plays in the given year
    - `date`: ascending by date of first play 
* `-v` or `--verbose` will also print number of plays in the given year and the date of the first play.
