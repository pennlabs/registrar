jsdom = require('jsdom')


ROSTER = "http://www.upenn.edu/registrar/roster/index.html"
JQUERY = "http://code.jquery.com/jquery-1.8.1.min.js"


# Map from day code to long name
DAYS =
    'M' : 'monday'
    'T' : 'tuesday'
    'W' : 'wednesday'
    'R' : 'thursday'
    'F' : 'friday'


# Matches the first line of a registrar formatted course
coursePattern = ///
    ^(\w{2,5})  # department code
    \s?\s?
    -(\d+)      # course number
    \s+
    (\D*)       # course name
    \s+
    (\d\.?\d?)  # credits
    .*
    ///

# Matches the second line of a registrar formatted course
sectionPattern = ///
    (\d{3})              # section number
    \s+
    (\w{3})              # section type (LEC | REC)
    \s+
    (.*(AM|PM|NOON|TBA)) # day and time
    \s+
    (\w+)                # location / room
    \s
    ([A-Za-z0-9]+)       # room number
    \s+
    (.*)                 # professor name
    ///


module.exports =
    # Parse days from a formatted string
    # >>> getDays "M 4:30-5:30PM"
    # ['monday']
    getDays: (str) ->
      str = str.match(/[a-zA-Z]+/)[0]
      DAYS[ch] for ch in str when DAYS[ch]

    # TODO: Get meridian at some point

    # Parse hours from a formatted string
    # >>> getHours "M 4:30-5:30PM"
    # ["4:30", "5:30"]
    getHours: (str) ->
      str = str.match(/([0-9:]+)-([0-9:]+)/)
      [str[1], str[2]]


    parseCourse: (line) ->
      match = coursePattern.exec(line)
      if match
        course =
          num     : match[2]
          title   : match[3].trim()
          credits : match[4]
        return course


    parseSection: (dept, course, line) ->
      match = sectionPattern.exec(line)
      if match
        section =
          dept          : dept
          title         : course.title
          courseNumber  : course.num
          sectionNumber : match[1]
          type          : match[2]
          times         : match[3]
          days          : @getDays match[3]
          hours         : @getHours match[3]
          building      : match[5]
          roomNumber    : match[6]
          prof          : match[7]
        return section


    # Reach each line in the roster of a department
    readRoster: (dept, cb) ->
      jsdom.env "http://www.upenn.edu/registrar/roster/#{dept.toLowerCase()}.html", [
          JQUERY
        ], (errors, window) ->
          $ = window.$

          # Get each line in the file
          lines = $('pre p:last-child').text().split('\n')
          cb? lines


    # Parse all the courses in a department
    getSections: (dept, cb) ->
      @readRoster dept, (lines) =>
        course = null
        lines.forEach (line) =>
          if newCourse = @parseCourse line
            course = newCourse
          else
            section = @parseSection dept, course, line
            cb? section if section?


    # Get each department and do something with it
    getDepartments: (cb) ->
      jsdom.env ROSTER, [
        JQUERY
      ], (errors, window) ->
        $ = window.$

        # The roster page doesn't use ids, so we are forced to identify the
        # table by checking content in it
        depts = $('tr:contains("Accounting")')[1]

        $(depts).find('tr').each (i, el) ->
          dept = $(el).find('td').eq(0).text()
          cb? dept
