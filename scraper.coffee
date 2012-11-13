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
    (\d{3})             # section number
    \s+
    (\w{3})             # section type (LEC | REC)
    \s+
    (.*(AM|PM|NOON|TBA))# day and time
    \s+
    (\w+)               # location / room
    \s
    ([A-Za-z0-9]+)      # room number
    \s+
    (.*)                # professor name
    ///


module.exports =
# Parse hours from a formatted string
# >>> getHours "M 4:30-5:30PM"
# ['monday']
    getDays: (str) ->
      str = str.match(/[a-zA-Z]+/)[0]
      DAYS[ch] for ch in str when DAYS[ch]


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
                'num': match[2]
                'title': match[3]
                'credits': match[4]
            return course


    # Parse all the courses in a department
    parseDept: (dept, cb) ->
        jsdom.env("http://www.upenn.edu/registrar/roster/#{dept}.html", [
            'http://code.jquery.com/jquery-1.8.1.min.js'
          ], (errors, window) ->
            $ = window.$

            # Get each line in the file
            lines = $('pre p:last-child').text().split('\n')

            course = null
            # iterate through each of the lines and
            #   -   try to match using the first line pattern
            #       -   if it works, grab the cousenum and title
            #       -   otherwise, try the second pattern
            #           - if it works, create a new object
            #           - otherwise, do nothing
            _.each(lines, (line) ->
              course = (parseCourse line) or course
              log line
              if course?
                  log course
              if not course?
                section = sectionPattern.exec(line)
                if section
                  log "section match"
                  doc =
                    dept          : dept
                    title         : course.title
                    course_num    : course.num
                    section_num   : section[1]
                    type          : section[2]
                    times         : section[3]
                    days          : getDays section[3]
                    hours         : getHours section[3]
                    building      : section[5]
                    room_num      : section[6]
                    prof          : section[7]

                  log "cb is had"
                  cb? doc
            )
        )


# Get each department and do something with it
    withDepts: (cb) ->
      jsdom.env('http://www.upenn.edu/registrar/roster/index.html', [
        'http://code.jquery.com/jquery-1.8.1.min.js'
      ], (errors, window) ->
      $ = window.$

          # The roster page doesn't use ids, so we are forced to identify the
          # table by checking content in it
          depts = $('tr:contains("Accounting")')[1]

          $(depts).find('tr').each (i, el) ->
            dept = $(el).find('td').eq(0).text()
            cb? dept
        )


    main: ->
      log "hello"
      # Log a JSON representation of each of the courses in a department
      withDepts (dept) ->
        parseDept dept.toLowerCase(), log
