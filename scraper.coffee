jsdom = require('jsdom')
url = require('url')
async = require('async')
_ = require('underscore')
log = console.log

parseDept = (item, cb) ->
    item = item.toLowerCase()
    jsdom.env("http://www.upenn.edu/registrar/roster/#{item}.html", [
        'http://code.jquery.com/jquery-1.8.1.min.js'
      ], (errors, window) ->
        $ = window.$
        deptText = $('pre p:last-child').text()
        classes = deptText.split('\n')
        curCourseNum = ""
        curTitle = ""
        firstLinePattern = /^(\w{2,5})\s?\s?-(\d{3})\s+(\w+.*?)\s+\d/
        infoLineNormalPattern = /(\d{3})\s+(\w{3})\s+(.*(AM|PM|NOON))\s+(\w+)\s([A-Za-z0-9]+)\s+(.*)/
        getDays = (str) ->
          str = str.match(/[a-zA-Z]+/)[0]
          hash =
            'M' : 'monday'
            'T' : 'tuesday'
            'W' : 'wednesday'
            'R' : 'thursday'
            'F' : 'friday'
          hash[ch] for ch in str when hash[ch]
        getHours = (str) ->
          str = str.match(/([0-9:]+)-([0-9:]+)/)
          [str[1], str[2]]
        _.each(classes, (cls) ->
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
              log doc
              # collection.insert doc, () ->
        )
        cb?()
    )

jsdom.env('http://www.upenn.edu/registrar/roster/index.html', [
    'http://code.jquery.com/jquery-1.8.1.min.js'
  ], (errors, window) ->
    $ = window.$
    acct = $('tr:contains("Accounting")')[1]
    $(acct).find('tr').each (i, el) ->
      curDept = $(el).find('td').eq(0).text()
      parseDept curDept
)
