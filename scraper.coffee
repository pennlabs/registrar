jsdom = require('jsdom')


ROSTER = "http://www.upenn.edu/registrar/roster/index.html"
JQUERY = "http://code.jquery.com/jquery-1.8.3.min.js"


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
      days = str.match(/[a-zA-Z]+/)[0]
      DAYS[day] for day in days when DAYS[day]

    # TODO: Get meridian at some point

    # Parse hours from a formatted string
    # >>> getHours "M 4:30-5:30PM"
    # ["4:30", "5:30"]
    getHours: (str) ->
      hours = str.match(/([0-9:]+)-([0-9:]+)/)
      [hours[1], hours[2]]


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
          credits       : course.credits
          sectionNumber : match[1]
          type          : match[2]
          times         : match[3]
          days          : @getDays match[3]
          hours         : @getHours match[3]
          building      : match[5]
          roomNumber    : match[6]
          prof          : match[7]
        return section


    # Read each line in the roster of a department
    readRoster: (dept, parseLine, cb) ->
      jsdom.env "http://www.upenn.edu/registrar/roster/#{dept.toLowerCase()}.html", [
          JQUERY
        ], (errors, window) ->
          $ = window.$
          # Get each line in the file and parse it
          lines = $('pre p:last-child').text().split('\n')
          lines.forEach parseLine if parseLine
          cb? lines


    # Parse all the courses in a department
    getCourses: (dept, cb) ->
      courses = []
      parseLine = (line) =>
        course = @parseCourse line
        courses.push course if course?
      success = => cb? courses
      @readRoster dept, parseLine, success


    # Parse all the sections in a department
    getSections: (dept, cb) ->
      sections = []
      course = null
      parseLine = (line) =>
        if newCourse = @parseCourse line
          course = newCourse
        else
          section = @parseSection dept, course, line
          sections.push section if section?
      success = => cb? sections
      @readRoster dept, parseLine, success


    # Get each department and do something with it
    getDepartments: (cb) ->
      jsdom.env ROSTER, [
        JQUERY
      ], (errors, window) ->
        $ = window.$

        # The roster page doesn't use ids, so we are forced to identify the
        # table by checking content in it
        department_rows = $('tr:contains("Accounting")')[1]

        depts = []
        $(department_rows).find('tr').map (i, el) ->
          dept = $(el).find('td').eq(0).text()
          depts.push dept
        cb? depts
