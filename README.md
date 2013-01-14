UPenn Registrar Course Scraper
================

A CoffeeScript module that scrapes the UPenn Registrar. Please install [node](nodejs.org) and [CoffeeScript](coffeescript.org).

# Quick Start

To build the CoffeeScript simple run `npm install && cake build`

Start an interactive CoffeeScript shell with `coffee`

Create a scraper object
``` coffeescript
Scraper = require "./scraper"
```

Print the list of departments
``` coffeescript
Scraper.getDepartments (depts) ->
  console.log depts
```

Print all the MATH courses
``` coffeescript
Scraper.getCourses "math", (courses) ->
  console.log courses
```

Print all the CIS courses with their sections
``` coffeescript
Scraper.getSections "cis", (sections) ->
  console.log sections
```

Get all the courses and sections for each department
``` coffeescript
Scraper.getDepartments (depts) ->
  for dept in depts
    Scraper.getSections dept, (sections) ->
      console.log sections
```

# Contributors

- Geoffrey Vedernikoff <veg@seas.upenn.edu>
- Ceasar Bautista <ceasarb@seas.upenn.edu>
