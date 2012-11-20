# assert = require("assert")
chai = require('chai')
chai.Assertion.includeStack = true
expect = chai.expect

scraper = require("../scraper")


describe 'getDays', () ->
  it "should return monday when M is present", ->
    expect(scraper.getDays 'M').to.deep.equal(['monday'])
  it "should return ['monday', 'wednesday'] when M and W is present", ->
    expect(scraper.getDays 'MW').to.deep.equal(['monday', 'wednesday'])


describe 'getHours', () ->
  it "should return ['4:30', '5:30'] when 4:30 and 5:30 are present", ->
    expect(scraper.getHours "M 4:30-5:30PM").to.deep.equal(['4:30', '5:30'])
  it "should return ['9', '10:30'] when 9 and 10:30 are present", ->
    expect(scraper.getHours "M 9-10:30AM").to.deep.equal(['9', '10:30'])


describe 'parseCourse', () ->
  it "should grab course num", ->
    line = "ACCT-718  AUDITING 1 CU"
    num = '718'
    course = scraper.parseCourse(line)
    expect(course.num).to.equal(num)
  it "should grab course name", ->
    line = "ACCT-718  AUDITING 1 CU"
    title = 'AUDITING'
    course = scraper.parseCourse(line)
    expect(course.title).to.equal(title)
  it "should grab course names with non-word characters", ->
    line = "ACCT-705 TAX PLANNING AND ADMIN. 1 CU"
    title = 'TAX PLANNING AND ADMIN.'
    course = scraper.parseCourse(line)
    expect(course.title).to.equal(title)
  it "should grab credits", ->
    line = "ACCT-718  AUDITING 1 CU"
    credits = '1'
    course = scraper.parseCourse(line)
    expect(course.credits).to.equal(credits)
  it "should grab half credits", ->
    line = "ACCT-612 ACCELERATED FIN ACCT 0.5 CU"
    credits = '0.5'
    course = scraper.parseCourse(line)
    expect(course.credits).to.equal(credits)
  it "should return undefined if there is no match", ->
    line = "     MBA COURSE"
    expect(scraper.parseCourse(line)).to.equal(undefined)


describe 'parseSection', () ->
  dept = 'acct'
  course =
      title: 'AUDITING'
      num: '718'
  line = "001 LEC MW 9-10:30AM JMHH F50         FISCHER P"
  section = scraper.parseSection dept, course, line
  it "should have dept", ->
    expect(section.dept).to.deep.equal('acct')
  it "should have title", ->
    expect(section.title).to.deep.equal('AUDITING')
  it "should have courseNumber", ->
    expect(section.courseNumber).to.deep.equal('718')
  it "should have sectionNumber", ->
    expect(section.sectionNumber).to.deep.equal('001')
  it "should have type", ->
    expect(section.type).to.deep.equal('LEC')
  it "should have times", ->
    expect(section.times).to.deep.equal('MW 9-10:30AM')
  it "should have days", ->
    expect(section.days).to.deep.equal(['monday', 'wednesday'])
  it "should have hours", ->
    expect(section.hours).to.deep.equal(['9', '10:30'])
  it "should have building", ->
    expect(section.building).to.deep.equal('JMHH')
  it "should have roomNumber", ->
    expect(section.roomNumber).to.deep.equal('F50')
  it "should have prof", ->
    expect(section.prof).to.deep.equal('FISCHER P')


describe 'getSections', () ->
  @timeout(0)
  it "should get each section in a department", =>
    scraper.getSections "cis", (sections) ->
      expect(sections.length).to.equal(142)

describe 'getDepartments', () ->
  @timeout(0)
  departments = []
  before (done) =>
    scraper.getDepartments ((department) =>
      departments.push department), =>
        done()
  it "should get each department", =>
    expect(departments.length).to.equal(145)
