jsdom = require('jsdom')
url = require('url')
async = require('async')
_ = require('underscore')
log = console.log


# Map from day code to long name
DAYS =
    'M' : 'monday'
    'T' : 'tuesday'
    'W' : 'wednesday'
    'R' : 'thursday'
    'F' : 'friday'


# Parse hours from a formatted string
# >>> getHours "M 4:30-5:30PM"
# ['monday']
getDays = (str) ->
  str = str.match(/[a-zA-Z]+/)[0]
  DAYS[ch] for ch in str when DAYS[ch]


# Parse hours from a formatted string
# >>> getHours "M 4:30-5:30PM"
# ["4:30", "5:30"]
getHours = (str) ->
  str = str.match(/([0-9:]+)-([0-9:]+)/)
  [str[1], str[2]]


# Matches the first line of a registrar formatted course
firstLinePattern = /// /^
    (\w{2,5})   # department code
    \s?\s?      # white space
    -(\d{3})    # course number
    \s+         # white space
    (\w+.*?)    # course name
    \s+         # white space
    \d/         # number (credit)
    ///


# Matches the second line of a registrar formatted course
infoLineNormalPattern = ///
    (\d{3})             # section number
    \s+
    (\w{3})             # section type (LEC | REC)
    \s+
    (.*(AM|PM|NOON))    # day and time
    \s+
    (\w+)               # location / room
    \s
    ([A-Za-z0-9]+)      # professor name
    \s+
    (.*)                # consume everything else
    ///


# Parse all the courses in a department
parseDept = (item, cb) ->
    jsdom.env("http://www.upenn.edu/registrar/roster/#{item}.html", [
        'http://code.jquery.com/jquery-1.8.1.min.js'
      ], (errors, window) ->
        $ = window.$

        classes = $('pre p:last-child').text().split('\n')

        curCourseNum = ""
        curTitle = ""

        _.each(classes, (cls) ->
          # try to match using the first line pattern
          # if it works, grab the cousenum and title
          # otherwise, match the second line and use the coursenum and title
          # to create a new object
          firstLine = firstLinePattern.exec(cls)
          if firstLine
            curCourseNum = firstLine[2]
            curTitle = firstLine[3]
          else
            infoLine = infoLineNormalPattern.exec(cls)
            if infoLine
              doc =
                dept          : item
                title         : curTitle
                course_num    : curCourseNum
                section_num   : infoLine[1]
                type          : infoLine[2]
                times         : infoLine[3]
                days          : getDays infoLine[3]
                hours         : getHours infoLine[3]
                building      : infoLine[5]
                room_num      : infoLine[6]
                prof          : infoLine[7]

              cb?(doc)
        )
    )


# Main function
jsdom.env('http://www.upenn.edu/registrar/roster/index.html', [
    'http://code.jquery.com/jquery-1.8.1.min.js'
  ], (errors, window) ->
    $ = window.$

    # Doesn't use ids
    # Find the table containing "Accounting"
    depts = $('tr:contains("Accounting")')[1]

    $(depts).find('tr').each (i, el) ->
      dept = $(el).find('td').eq(0).text()
      # Log a JSON representation of each of the courses in a department
      parseDept dept.toLowerCase(), log
)
